# frozen_string_literal: true

# https://docs.rubocop.org/rubocop/formatters.html
# rubocop:disable Metrics/AbcSize, Metrics/MethodLength
class RdjsonFormatter < RuboCop::Formatter::BaseFormatter
  include RuboCop::PathUtil

  def started(_target_files)
    @rdjson = {
      source: {
        name: 'rubocop',
        url: 'https://rubocop.org/'
      },
      diagnostics: []
    }
    super
  end

  def file_finished(file, offenses)
    offenses.each do |offense|
      next if offense.location == RuboCop::Cop::Offense::NO_LOCATION

      @rdjson[:diagnostics] << build_diagnostic(file, offense)
    end
  end

  def finished(_inspected_files)
    puts @rdjson.to_json
  end

  private

  # @param [String] file
  # @param [RuboCop::Cop::Offense] offense
  # @return [Hash]
  def build_diagnostic(file, offense)
    code, message = offense.message.split(':', 2).map(&:strip)

    diagnostic = {
      message: message,
      location: {
        path: convert_path(file),
        range: {
          start: {
            line: offense.location.begin.line,
            column: offense.location.begin.column + 1
          },
          end: {
            line: offense.location.end.line,
            column: offense.location.end.column + 1
          }
        }
      },
      severity: convert_severity(offense.severity),
      code: {
        value: code
      },
      original_output: build_original_output(file, offense)
    }

    diagnostic[:suggestions] = build_suggestions(offense) if offense.correctable? && offense.corrector

    diagnostic
  end

  # @param [RuboCop::Cop::Offense] offense
  # @return [Array{Hash}]
  def build_suggestions(offense)
    range, text = offense.corrector.as_replacements[0]

    [
      {
        range: {
          start: {
            line: range.begin.line,
            column: range.begin.column + 1 # rubocop is 0-origin, reviewdog is 1-origin
          },
          end: {
            line: range.end.line,
            column: range.end.column + 1
          }
        },
        text: text
      }
    ]
  end

  # https://github.com/reviewdog/reviewdog/blob/1d8f6d6897dcfa67c33a2ccdc2ea23a8cca96c8c/proto/rdf/reviewdog.proto
  # https://docs.rubocop.org/rubocop/configuration.html#severity
  #
  # @param [Symbol] severity
  # @return [String]
  def convert_severity(severity)
    case severity
    when :info
      'INFO'
    when :warning
      'WARNING'
    when :error
      'ERROR'
    else
      'UNKNOWN_SEVERITY'
    end
  end

  # extract reasonable relative path from (ideally) the project root.
  # if `path` is `"/path/to/project/lib/my_file.rb"`,
  # it generates `"lib/my_file.rb"` as
  #
  # ref: rubocop approach
  # https://github.com/rubocop/rubocop/blob/1e55b1aa5e4c5eaeccad5d61f08b7930ed6bc341/lib/rubocop/path_util.rb#L25
  #
  # @param [String] path
  # @return [String]
  def convert_path(path)
    base_path = Dir.pwd

    begin
      Pathname.new(File.expand_path(path)).relative_path_from(base_path).to_s
    rescue ArgumentError
      path
    end
  end

  # @param [String] file
  # @param [RuboCop::Cop::Offense] offense
  # @return [String]
  def build_original_output(file, offense)
    format(
      '%<path>s:%<line>d:%<column>d: %<severity>s: %<message>s',
      path: smart_path(file),
      line: offense.line,
      column: offense.real_column,
      severity: offense.severity.code,
      message: offense.message
    )
  end
end
# rubocop:enable Metrics/AbcSize, Metrics/MethodLength
