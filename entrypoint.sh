#!/usr/bin/env bash

cat output_rdjson.json  | reviewdog -f=rdjson -reporter=github-pr-review -level=warning
