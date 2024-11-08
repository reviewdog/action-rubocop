# frozen_string_literal: true

# https://docs.rubocop.org/rubocop/formatters.html
# rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/ClassLength
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
      @rdjson[:diagnostics] << build_diagnostic(file, offense)
    end

    @rdjson[:severity] = overall_severity(offenses)
  end

  def finished(_inspected_files)
    puts @rdjson.to_json
  end

  private

  def overall_severity(offenses)
    if offenses.any? { |o| o.severity >= minimum_severity_to_fail }
      'ERROR'
    elsif offenses.all? { |o| convert_severity(o.severity) == 'INFO' }
      'INFO'
    else
      'WARNING'
    end
  end

  def minimum_severity_to_fail
    @minimum_severity_to_fail ||= begin
      # Unless given explicitly as `fail_level`, `:info` severity offenses do not fail
      name = options.fetch(:fail_level, :refactor)
      RuboCop::Cop::Severity.new(name)
    end
  end

  # @param [String] file
  # @param [RuboCop::Cop::Offense] offense
  # @return [Hash]
  def build_diagnostic(file, offense)
    code, message = offense.message.split(':', 2).map(&:strip)

    diagnostic = {
      message: message,
      location: {
        path: convert_path(file)
      },
      severity: convert_severity(offense.severity),
      code: {
        value: code
      },
      original_output: build_original_output(file, offense)
    }
    diagnostic[:location][:range] = build_range(offense) if offense.location != RuboCop::Cop::Offense::NO_LOCATION

    diagnostic[:suggestions] = build_suggestions(offense) if offense.correctable? && offense.corrector

    diagnostic
  end

  # @param [RuboCop::Cop::Offense] offense
  # @return [Hash]
  def build_range(offense)
    {
      start: {
        line: offense.location.begin.line,
        column: offense.location.begin.column + 1
      },
      end: {
        line: offense.location.end.line,
        column: offense.location.end.column + 1
      }
    }
  end

  # @param [RuboCop::Cop::Offense] offense
  # @return [Array{Hash}]
  def build_suggestions(offense)
    return [] unless offense.correctable? && offense.corrector

    source_buffer = offense.location.source_buffer
    corrections = offense.corrector.as_replacements
    return [] if corrections.empty?

    min_begin_pos = corrections.map { |range, _| range.begin_pos }.min
    max_end_pos = corrections.map { |range, _| range.end_pos }.max
    merged_range = Parser::Source::Range.new(source_buffer, min_begin_pos, max_end_pos)

    corrected_text = ''
    current_pos = min_begin_pos

    sorted_corrections = corrections.sort_by { |range, _| range.begin_pos }

    sorted_corrections.each do |range, replacement_text|
      next if range.end_pos < min_begin_pos || range.begin_pos > max_end_pos

      corrected_text += source_buffer.source[current_pos...range.begin_pos] if current_pos < range.begin_pos
      corrected_text += replacement_text.to_s
      current_pos = range.end_pos
    end

    corrected_text += source_buffer.source[current_pos...max_end_pos] if current_pos < max_end_pos

    [{
      range: {
        start: {
          line: merged_range.line,
          column: merged_range.column + 1 # rubocop is 0-origin, reviewdog is 1-origin
        },
        end: {
          line: merged_range.last_line,
          column: merged_range.last_column + 1
        }
      },
      text: corrected_text
    }]
  end

  # https://github.com/reviewdog/reviewdog/blob/1d8f6d6897dcfa67c33a2ccdc2ea23a8cca96c8c/proto/rdf/reviewdog.proto
  # https://docs.rubocop.org/rubocop/configuration.html#severity
  #
  # @param [Symbol] severity
  # @return [String]
  def convert_severity(severity)
    case severity.to_s
    when 'info', 'refactor', 'convention'
      'INFO'
    when 'warning'
      'WARNING'
    when 'error'
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
      Pathname.new(File.expand_path(path)).relative_path_from(Pathname.new(base_path)).to_s
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
# rubocop:enable Metrics/AbcSize, Metrics/MethodLength, Metrics/ClassLength
