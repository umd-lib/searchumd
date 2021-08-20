# SearchUMD

## Introduction

UMD Libraries bento-box search application, based on the NSCU QuickSearch
Rails engine ([https://github.com/NCSU-Libraries/quick_search][quick_search]).

This application wraps the NCSU QuickSearch engine.

Note: This application is currently using a UMD-customized fork of the
NCSU QuickSearch application at
[https://github.com/umd-lib/quick_search][umd_quick_search].

## Quick Start

Requires:

* Ruby 2.6.5
* Bundler

### Local Development Setup

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

3) Copy the "env_example" file to ".env":

```
> cp env_example .env
```

4) Edit the ".env" file:

```
> vi .env
```

configuring the following variables as appropriate:

* DATABASE_FINDER_HIPPO_SITE_URL - a Hippo base URL, such as
    <https://www.lib.umd.edu/>
* LIB_ANSWERS_IID
* LIB_GUIDES_SITE_ID
* LIB_GUIDES_API_KEY
* WORLD_CAT_DISCOVERY_API_INSTITUTION_ID
* WORLD_CAT_DISCOVERY_API_WSKEY
* WORLD_CAT_DISCOVERY_API_SECRET
* WORLD_CAT_OPEN_URL_RESOLVER_WSKEY

The values for these variables can be found in the
"SSDR/Bento Box Discovery Pilot/search-dev.lib.umd.edu API Keys Google Drive"
document on Google Drive.

5) To run the web application:

```
> rails server
```

The application should be accessible at:

<http://localhost:3000/>

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

## Docker Image

This application provides a Dockerfile for generating a Docker image
of the "searchumd" application for use in production.

In order to generate a "clean" Docker image, the Docker image should be
built from a fresh clone of the GitHub repository.

### Generating a New Docker Image

The following steps can be done on any workstation (i.e., your MacBook):

#### 1) Verify that the "Gemfile" contains the searcher versions to use

The searchers used by the application should be specified by Git tag in the
"Gemfile".

If branch versions are used (for testing), run `bundle update <GEM>` (where
\<GEM> is the name of the gem) to ensure that the "Gemfile.lock" file is
updated with the latest changes from that branch.

#### 2) Build the Docker image for the searchumd application

Build the Docker image, replacing \<VERSION> with the "searchumd" application
version:

```
> docker build --no-cache -t docker.lib.umd.edu/searchumd:<VERSION> -f Dockerfile .
```

For example, for searchumd v1.0.0, the command would be:

```
> docker build --no-cache -t docker.lib.umd.edu/searchumd:1.0.0 -f Dockerfile .
```

**Note:** The "--no-cache" option is used to force Docker to download the
latest version of any images, instead of relying on whatever might be in the
cache on a particular workstation.

#### 3) Push the "searchumd" Docker image to the Nexus

Push the "searchumd" image up to the private UMD Docker registry, replacing
\<VERSION> with the "searchumd" application version:

```
> docker push docker.lib.umd.edu/searchumd:<VERSION>
```

For example, for searchumd v1.0.0, the command would be:

```
> docker push docker.lib.umd.edu/searchumd:1.0.0
```

[quick_search]: https://github.com/NCSU-Libraries/quick_search
[umd_quick_search]: https://github.com/umd-lib/quick_search
[docker]: https://docs.docker.com/storage/volumes/#backup-restore-or-migrate-data-volumes
