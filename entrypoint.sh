#!/bin/sh
version() {
  if [ -n "$1" ]; then
    echo "-v $1"
  fi
}

install_extensions() {
  if [ -n "$1" ]; then
    echo "$1" | sed "s/[^ ][^ ]*/'&'/g" | xargs gem install
  else
    gem install -N rubocop-rails rubocop-performance rubocop-rspec rubocop-i18n rubocop-rake
  fi
}

cd "$GITHUB_WORKSPACE"

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

gem install rubocop $(version $INPUT_RUBOCOP_VERSION)

install_extensions ${INPUT_RUBOCOP_EXTENSIONS}

rubocop ${INPUT_RUBOCOP_FLAGS} \
  | reviewdog -f=rubocop -name="${INPUT_TOOL_NAME}" -reporter="${INPUT_REPORTER}" -level="${INPUT_LEVEL}"
