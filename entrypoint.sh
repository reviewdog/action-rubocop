#!/usr/bin/env bash

cat /output_rdjson.json  | /usr/local/bin/reviewdog -f=rdjson -reporter=github-pr-review -level=warning
