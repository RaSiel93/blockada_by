FROM ruby:latest

WORKDIR app

RUN gem install rails bundler
RUN gem install rails

COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN bundle

COPY . .

# CMD ["/bin/bash"]
