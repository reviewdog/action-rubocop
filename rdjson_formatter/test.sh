#!/bin/bash
# Expected to run from the root repository.
set -eux
CWD=$(pwd)
rubocop ./testdata/*.rb --require ./rdjson_formatter/rdjson_formatter.rb --format RdjsonFormatter --cache false \
  | jq . \
  | sed -e "s!${CWD}/!!g" \
  > rdjson_formatter/testdata/result.out
diff -u rdjson_formatter/testdata/result.*
