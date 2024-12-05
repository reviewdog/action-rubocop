FROM ruby:3.3

RUN apt-get update && apt-get install -y \
  build-essential \
  libssl-dev \
  libreadline-dev \
  zlib1g-dev \
  && rm -rf /var/lib/apt/lists/*

RUN useradd -ms /bin/bash vscode

WORKDIR /workspace

RUN gem install bundler

COPY . .

RUN bundle install

ENV RACK_ENV=development

RUN apt-get update && apt-get install -y \
  vim \
  git \
  jq \
  && rm -rf /var/lib/apt/lists/*

USER vscode

CMD ["bash"]
