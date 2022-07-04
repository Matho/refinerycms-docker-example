FROM mathosk/ruby-2.6.5-ubuntu:latest as builder

MAINTAINER Matho "martin.markech@matho.sk"

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    curl \
    vim \
    git \
    build-essential \
    libgmp-dev \
    libpq-dev \
    locales \
    nginx \
    cron \
    bash \
    imagemagick \
    python \
    nodejs \
    npm \
    libcurl4 \
    libcurl4-openssl-dev

RUN npm install --global yarn

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

# TODO is this needed?
# ARG BUNDLE_CODE__MATHO__SK
ARG RAILS_ENV

ADD ./Gemfile ./Gemfile
ADD ./Gemfile.lock ./Gemfile.lock

RUN gem install bundler -v '~> 2.1.1'
# if you have some additional private gems on Gitlab, replace password with your oauth personal token and uncomment the line
# RUN bundle config gitlab.com oauth2:password
RUN bundle install --deployment --clean --path vendor/bundle --without development test --jobs 8

COPY package.json yarn.lock $APP_HOME/
RUN yarn install  --check-files

COPY . $APP_HOME

ADD .env.development .env.development
ADD .env.production .env.production

RUN bundle exec rake assets:precompile --verbose

RUN rm -rf $APP_HOME/node_modules
RUN rm -rf $APP_HOME/tmp/*

FROM mathosk/ruby-2.6.5-ubuntu:latest

RUN apt-get update && apt-get install -y \
    curl \
    vim \
    git \
    build-essential \
    libgmp-dev \
    libpq-dev \
    locales \
    nginx \
    cron \
    bash \
    imagemagick \
    python \
    libcurl4 \
    libcurl4-openssl-dev \
    exiftool

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

# Set Nginx config
ADD config/etc/nginx/conf.d/nginx.docker.conf /etc/nginx/conf.d/default.conf
RUN rm /etc/nginx/sites-enabled/default

COPY --from=builder /app $APP_HOME

ENV RAILS_ENV=production

RUN bundle config --local path vendor/bundle

RUN bundle config --local without development:test:assets

EXPOSE 80

CMD bin/run.docker.sh


