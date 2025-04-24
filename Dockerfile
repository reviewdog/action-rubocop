FROM ubuntu:24.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists
COPY entrypoint.sh .
COPY output_rdjson.json .

ENTRYPOINT ["entrypoint.sh"]
