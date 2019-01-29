FROM ruby:2.6-alpine

LABEL maintainer="me@agorf.gr"

RUN apk update && apk add build-base

WORKDIR /usr/src/app/

COPY Gemfile Gemfile.lock *.rb ./

RUN bundle install

CMD ["bundle", "exec", "ruby", "slack_poster.rb"]
