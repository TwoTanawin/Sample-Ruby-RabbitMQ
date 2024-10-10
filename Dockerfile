# Dockerfile
FROM ruby:3.3.4

# Install dependencies
RUN apt-get update -qq && apt-get install -y postgresql-client

# Set working directory
WORKDIR /app

# Copy Gemfile and install gems
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install

# Copy application files
COPY . /app
