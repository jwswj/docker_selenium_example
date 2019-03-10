FROM ruby:2.5.1

# Install dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
      build-essential \
      libpq-dev \
      wget \
      apt-transport-https \
      git \
      curl \
      gnupg2 \
  && curl -sL https://deb.nodesource.com/setup_6.x | bash - \
  && apt-get install nodejs -y \
  && curl -fsSL https://get.docker.com | bash - \
  && wget -qc https://github.com/betalo-sweden/await/releases/download/v0.4.0/await-linux-amd64 \
  && install await-linux-amd64 /usr/local/bin/await \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

ADD Gemfile Gemfile.lock /app/
RUN gem install bundler \
    && bundle install --jobs $(nproc)

# ADD package.json package-lock.json /app/
# RUN npm install

# ADD client/package.json client/package-lock.json /app/client/
# RUN cd client && npm install

COPY . /app/

RUN ln -s .env.test .env

# Assets
RUN bundle exec rake assets:precompile
