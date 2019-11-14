#!/bin/sh

cd "$GITHUB_WORKSPACE"

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

rubocop ${INPUT_RUBOCOP_FLAGS} \
  | reviewdog -f=rubocop -name="${INPUT_TOOL_NAME}" -reporter=github-pr-check -level="${INPUT_LEVEL}"
