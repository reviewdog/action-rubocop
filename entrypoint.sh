#!/bin/sh
version() {
  if [ -n "$1" ]; then
    echo "-v $1"
  fi
}

cd "$GITHUB_WORKSPACE"

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

gem install rubocop $(version $INPUT_RUBOCOP_VERSION)
gem install rubocop-rails $(version $INPUT_RUBOCOP_RAILS_VERSION)
gem install rubocop-performance $(version $INPUT_RUBOCOP_PERFORMANCE_VERSION)
gem install rubocop-rspec $(version $INPUT_RUBOCOP_RSPEC_VERSION)
gem install rubocop-i18n $(version $INPUT_RUBOCOP_I18N_VERSION)
gem install rubocop-rake $(version $INPUT_RUBOCOP_RAKE_VERSION)

rubocop ${INPUT_RUBOCOP_FLAGS} \
  | reviewdog -f=rubocop -name="${INPUT_TOOL_NAME}" -reporter="${INPUT_REPORTER}" -level="${INPUT_LEVEL}"
