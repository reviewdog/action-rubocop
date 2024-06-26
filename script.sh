#!/usr/bin/env bash

set -e
set -o pipefail

cd "${GITHUB_WORKSPACE}/${INPUT_WORKDIR}" || exit
export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

TEMP_PATH="$(mktemp -d)"
PATH="${TEMP_PATH}:$PATH"

echo '::group::🐶 Installing reviewdog ... https://github.com/reviewdog/reviewdog'
curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh | sh -s -- -b "${TEMP_PATH}" "${REVIEWDOG_VERSION}" 2>&1
echo '::endgroup::'

if [ "${INPUT_SKIP_INSTALL}" = "false" ]; then
  echo '::group:: Installing rubocop with extensions ... https://github.com/rubocop/rubocop'
  # if 'gemfile' rubocop version selected
  if [ "${INPUT_RUBOCOP_VERSION}" = "gemfile" ]; then
    # if Gemfile.lock is here
    if [ -f 'Gemfile.lock' ]; then
      # grep for rubocop version
      RUBOCOP_GEMFILE_VERSION=$(ruby -ne 'print $& if /^\s{4}rubocop\s\(\K.*(?=\))/' Gemfile.lock)

      # if rubocop version found, then pass it to the gem install
      # left it empty otherwise, so no version will be passed
      if [ -n "$RUBOCOP_GEMFILE_VERSION" ]; then
        RUBOCOP_VERSION=$RUBOCOP_GEMFILE_VERSION
      else
        printf "Cannot get the rubocop's version from Gemfile.lock. The latest version will be installed."
      fi
    else
      printf 'Gemfile.lock not found. The latest version will be installed.'
    fi
  else
    # set desired rubocop version
    RUBOCOP_VERSION=$INPUT_RUBOCOP_VERSION
  fi

  gem install -N rubocop --version "${RUBOCOP_VERSION}"

  # Traverse over list of rubocop extensions
  for extension in $INPUT_RUBOCOP_EXTENSIONS; do
    # grep for name and version
    INPUT_RUBOCOP_EXTENSION_NAME=$(echo "$extension" |awk 'BEGIN { FS = ":" } ; { print $1 }')
    INPUT_RUBOCOP_EXTENSION_VERSION=$(echo "$extension" |awk 'BEGIN { FS = ":" } ; { print $2 }')

    # if version is 'gemfile'
    if [ "${INPUT_RUBOCOP_EXTENSION_VERSION}" = "gemfile" ]; then
      # if Gemfile.lock is here
      if [ -f 'Gemfile.lock' ]; then
        # grep for rubocop extension version
        RUBOCOP_EXTENSION_GEMFILE_VERSION=$(ruby -ne "print $& if /^\s{4}$INPUT_RUBOCOP_EXTENSION_NAME\s\(\K.*(?=\))/" Gemfile.lock)

        # if rubocop extension version found, then pass it to the gem install
        # left it empty otherwise, so no version will be passed
        if [ -n "$RUBOCOP_EXTENSION_GEMFILE_VERSION" ]; then
          RUBOCOP_EXTENSION_VERSION=$RUBOCOP_EXTENSION_GEMFILE_VERSION
        else
          printf "Cannot get the rubocop extension version from Gemfile.lock. The latest version will be installed."
        fi
      else
        printf 'Gemfile.lock not found. The latest version will be installed.'
      fi
    else
      # set desired rubocop extension version
      RUBOCOP_EXTENSION_VERSION=$INPUT_RUBOCOP_EXTENSION_VERSION
    fi

    # Handle extensions with no version qualifier
    if [ -z "${RUBOCOP_EXTENSION_VERSION}" ]; then
      unset RUBOCOP_EXTENSION_VERSION_FLAG
    else
      RUBOCOP_EXTENSION_VERSION_FLAG="--version ${RUBOCOP_EXTENSION_VERSION}"
    fi

    # shellcheck disable=SC2086
    gem install -N "${INPUT_RUBOCOP_EXTENSION_NAME}" ${RUBOCOP_EXTENSION_VERSION_FLAG}
  done
  echo '::endgroup::'
fi

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

if [ "${INPUT_USE_BUNDLER}" = "false" ]; then
  BUNDLE_EXEC=""
else
  BUNDLE_EXEC="bundle exec "
fi

if [ "${INPUT_ONLY_CHANGED}" = "true" ]; then
  echo '::group:: Getting changed files list'

  # get intersection of changed files (excluding deleted) with target files for
  # rubocop as an array
  # shellcheck disable=SC2086
  readarray -t CHANGED_FILES < <(
    comm -12 \
      <(git diff --diff-filter=d --name-only "${BASE_REF}..${HEAD_REF}" | sort || kill $$) \
      <(${BUNDLE_EXEC}rubocop --list-target-files | sort || kill $$)
  )

  if (( ${#CHANGED_FILES[@]} == 0 )); then
    echo "No relevant files for rubocop, skipping"
    exit 0
  fi

  printf '%s\n' "${CHANGED_FILES[@]}"

  if (( ${#CHANGED_FILES[@]} > 100 )); then
    echo "More than 100 changed files (${#CHANGED_FILES[@]}), running rubocop on all files"
    unset CHANGED_FILES
  fi

  echo '::endgroup::'
fi

echo '::group:: Running rubocop with reviewdog 🐶 ...'
# shellcheck disable=SC2086
${BUNDLE_EXEC}rubocop \
  ${INPUT_RUBOCOP_FLAGS} \
  --require ${GITHUB_ACTION_PATH}/rdjson_formatter/rdjson_formatter.rb \
  --format RdjsonFormatter \
  --fail-level error \
  "${CHANGED_FILES[@]}" \
  | reviewdog -f=rdjson \
      -name="${INPUT_TOOL_NAME}" \
      -reporter="${INPUT_REPORTER}" \
      -filter-mode="${INPUT_FILTER_MODE}" \
      -fail-on-error="${INPUT_FAIL_ON_ERROR}" \
      -level="${INPUT_LEVEL}" \
      ${INPUT_REVIEWDOG_FLAGS}

reviewdog_rc=$?
echo '::endgroup::'
exit $reviewdog_rc
