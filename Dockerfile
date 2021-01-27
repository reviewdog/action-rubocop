FROM ruby:3.0.0-alpine as builder

RUN apk add --update --no-cache git cmake make g++ pcre-tools openssl-dev

COPY Gemfile* /tmp/
RUN cd /tmp && bundle

FROM ruby:3.0.0-alpine

ENV REVIEWDOG_VERSION v0.11.0

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
RUN wget -O - -q https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh| sh -s -- -b /usr/local/bin/ $REVIEWDOG_VERSION

COPY --from=builder /usr/local/bundle/ /usr/local/bundle/

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

VOLUME /src
WORKDIR /src
