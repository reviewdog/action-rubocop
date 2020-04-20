FROM ruby:2.7.1-alpine

ENV REVIEWDOG_VERSION v0.9.17
ENV RUBOCOP_VERSION 0.82

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
RUN apk add --update --no-cache build-base git cmake openssl-dev
RUN wget -O - -q https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh| sh -s -- -b /usr/local/bin/ $REVIEWDOG_VERSION
RUN gem install -N rubocop:$RUBOCOP_VERSION \
                   rubocop-rails \
                   rubocop-performance \
                   rubocop-rspec \
                   rubocop-i18n \
                   rubocop-rake \
                   pronto \
                   pronto-rubocop

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

VOLUME /src
WORKDIR /src
