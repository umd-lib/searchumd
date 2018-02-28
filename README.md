# SearchUMD

## Introduction

UMD Libraries bento-box search application, based on the NSCU Quick Search
Rails engine ([https://github.com/NCSU-Libraries/quick_search][1])

This application wraps the NCSU Quick Search engine.

## Quick Start

Requires:

* Ruby 2.2.4
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


## Production Environment Configuration

Requires:

* Postgres client to be installed (on RedHat, the "postgresql" and
  "postgresql-devel" packages)
* MySQL client to be installed (on RedHat, the "mysql-devel"). This is a
  requirement from the NCSU Quick Search Rails engine.

The application uses the "dotenv" gem to configure the production environment.
The gem expects a ".env" file in the root directory to contain the environment
variables that are provided to Ruby. A sample "env_example" file has been
provided to assist with this process. Simply copy the "env_example" file to
".env" and fill out the parameters as appropriate.

The configured .env file should _not_ be checked into the Git repository, as it
contains credential information.

[1]: https://github.com/NCSU-Libraries/quick_search
