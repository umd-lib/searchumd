# SearchUMD

## Introduction

UMD Libraries bento-box search application, based on the NSCU Quick Search
Rails engine ([https://github.com/NCSU-Libraries/quick_search][1])

This application wraps the NCSU Quick Search engine.

## Quick Start

Requires:

* Ruby 2.3.7
* Bundler

### Setup

1) Clone this repository.

2) Install the dependencies:

```
> gem install bundler
> bundle install --without production
```

2) Set up the database:

```
> rails db:reset
```

3) To run the web application:

```
> rails server
```

## Environment Configuration

Some searchers used by this application require API keys to perform searches.
To keep these keys secure, and out of the GitHub repository, these keys are
should be configured through the environment.

The application uses the "dotenv" gem to configure the environment.
The gem expects a ".env" file in the root directory to contain the environment
variables that are provided to Rails. A sample "env_example" file has been
provided to assist with this process. Simply copy the "env_example" file to
".env" and fill out the parameters as appropriate.

The configured .env file should _not_ be checked into the Git repository, as it
contains credential information.

## Docker Images

This application provides the following Dockerfiles for generating Docker images
for use in production:

* Dockerfile - Generates image for the searchumd Rails application
* Dockerfile-nginx - Generates image for the Nginx web server providing HTTPS
    and port redirection.
* Dockerfile-solr - Generates images for the Solr search application

The "docker_config" directory contains files used by the Dockerfiles.

In order to generate "clean" Docker images, the Docker images should be
built from a fresh clone of the GitHub repository.

[1]: https://github.com/NCSU-Libraries/quick_search
