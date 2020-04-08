#!/bin/sh

cd "$GITHUB_WORKSPACE"

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

gem install -N rubocop -v ${INPUT_RUBOCOP_VERSION} \
 rubocop-rails -v ${INPUT_RUBOCOP_RAILS_VERSION} \
  rubocop-performance -v ${INPUT_RUBOCOP_PERFORMANCE_VERSION} \
   rubocop-rspec -v ${INPUT_RUBOCOP_RSPEC_VERSION} \
    rubocop-i18n -v ${INPUT_RUBOCOP_I18N_VERSION} \
     rubocop-rake -v ${INPUT_RUBOCOP_RAKE_VERSION}

rubocop ${INPUT_RUBOCOP_FLAGS} \
  | reviewdog -f=rubocop -name="${INPUT_TOOL_NAME}" -reporter="${INPUT_REPORTER}" -level="${INPUT_LEVEL}"
