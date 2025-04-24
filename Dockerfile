FROM ubuntu:24.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl \
    && curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh | sh -s -- -b /usr/local/bin \
    && apt-get remove -y ca-certificates curl \
    && rm -rf /var/lib/apt/lists
COPY entrypoint.sh .
COPY output_rdjson.json .

ENTRYPOINT ["/entrypoint.sh"]
