# Dockerfile for the generating searchumd Rails application Docker image
#
# To build:
#
# docker build -t docker.lib.umd.edu/searchumd:<VERSION> -f Dockerfile .
#
# where <VERSION> is the Docker image version to create.

FROM ruby:2.3.7-slim

# Install apt based dependencies required to run Rails as
# well as RubyGems. As the Ruby image itself is based on a
# Debian image, we use apt-get to install those.
RUN apt-get update && \
    apt-get install -y build-essential nodejs git libsqlite3-dev libmysqlclient-dev \
                       libpq-dev curl && \
    apt-get clean

# Create a user for the web app.
RUN addgroup --gid 9999 app
RUN adduser --uid 9999 --gid 9999 --disabled-password --gecos "Application" app
RUN usermod -L app
RUN mkdir -p /home/app/.ssh
RUN chmod 700 /home/app/.ssh
RUN chown app:app /home/app/.ssh
    
# Configure the main working directory. This is the base
# directory used in any further RUN, COPY, and ENTRYPOINT
# commands.

USER app
WORKDIR /home/app

ENV RAILS_ENV=production

# Copy the Gemfile as well as the Gemfile.lock and install
# the RubyGems. This is a separate step so the dependencies
# will be cached unless changes to one of those two files
# are made.
COPY --chown=app:app Gemfile Gemfile.lock /home/app/webapp/
RUN cd /home/app/webapp && \
    gem install bundler && \
    bundle install --jobs 20 --retry 5 --without development test && \
    cd ..
    
# Copy the main application.
COPY  --chown=app:app . /home/app/webapp/

ENV RAILS_RELATIVE_URL_ROOT=/search
ENV SCRIPT_NAME=/search

RUN cd /home/app/webapp && \
    bundle exec rails assets:precompile && \
    cd ..

# Expose port 3000 to the Docker host, so we can access it
# from the outside.
EXPOSE 3000

# The main command to run when the container starts. Also
# tell the Rails dev server to bind to all interfaces by
# default.
CMD cd /home/app/webapp && bundle exec rails db:migrate && bundle exec rails server -b 0.0.0.0
