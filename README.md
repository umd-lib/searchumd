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

3) Copy the "env_example" file to ".env" and configure.

4) To run the web application:

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

## Development Setup

The quick_search-library_website_searcher requires a Solr instance containing
search results. To set up a Solr instance use one of the following two methods:

### Method 1: Create and Populating Solr using Nutch

In this method, a Solr instance will be created and populated using Apache
Nutch. Use this method if you don't have a Solr data backup.

1) Create a Docker image "searchumd-solr:dev" using the Dockerfile-solr:

```
> docker build -t searchumd-solr:dev -f Dockerfile-solr .
```

2) Create a Docker bridge network named "dev_network":

```
> docker network create dev_network
```

2) Run a Docker container with the Solr image, naming it "solr_app", specifying
the "dev_network", and making it accessible from [http://localhost:8983/][solr]:

```
> docker run --rm -p 8983:8983 --network dev_network --name solr_app --mount source=solr-data,destination=/opt/solr/server/solr/nutch searchumd-solr:dev
```

The Solr data will be persisted in a Docker volume named "solr-data" and the
Solr instance should now be available via a web browser at:

[http://localhost:8983/solr][solr]

3) To populate the Solr container, do the following:

a) Create a Docker image "searchumd-nutch:dev" using the Dockerfile-nutch:

```
> docker build -t searchumd-nutch:dev -f Dockerfile-nutch .
```

b) Run Nutch, using only two crawl iterations, placing the result in the local
Solr "solr_app" instance, via the "dev_network" network:

```
> docker run --rm --network dev_network searchumd-nutch:dev bin/crawl -i -D solr.server.url=http://solr_app:8983/solr/nutch -s /root/nutch/urls/ LibCrawl/ 2
```

**Note:** If you want to preserve the Apache Nutch crawl data between container
runs, use a Docker volume (named "nutch-data" in this example) by running
the following command:

```
> docker run --rm --mount source=nutch-data,destination=/root/nutch/LibCrawl --network dev_network searchumd-nutch:dev bin/crawl -i -D solr.server.url=http://solr_app:8983/solr/nutch -s /root/nutch/urls/ LibCrawl/ 2
```

### Method 2: Create and Populating Solr from a Solr backup file

Use this method if you have a Solr data backup, or can retrieve one from some
source.

See [https://docs.docker.com/storage/volumes/#backup-restore-or-migrate-data-volumes][docker]
for more information about backing up and restoring data volumes.

#### Creating the Solr Backup

**Note:** This step can be skipped if you already have a Solr data backup.

In order to populate Solr from a backup file, we first need the data. To
retrieve the data from a Docker data volume (named "solr-data" in this
example) do the following:

1) Run a "ubuntu" container with the "solr-data" volume mounted, and run the
"tar" command:

```
> docker run --rm -v `pwd`:/backup --mount source=solr-data,destination=/root/solr ubuntu tar -cvf /backup/backup-solr.tar /root/solr
```

This will create a "backup-solr.tar" file in the current directory.

#### Populating a new data volume

1) Create a Docker volume named "solr-data":

```
> docker volume create solr-data
```

2) Run a "ubuntu" container and place the data from the backup-solr.tar into
the volume:

```
> docker run --rm -v `pwd`:/backup --mount source=solr-data,destination=/root/solr ubuntu bash -c  "cd /root/solr && tar -xvf /backup/backup-solr.tar --strip 1"
```

3) Create a Docker image "searchumd-solr:dev" using the Dockerfile-solr:

```
> docker build -t searchumd-solr:dev -f Dockerfile-solr .
```

4) Create a Docker bridge network named "dev_network":

```
> docker network create dev_network
```

5) Run a Docker container with the Solr image, naming it "solr_app", specifying
the "dev_network", and making it accessible from [http://localhost:8983/][solr]:

```
> docker run --rm -p 8983:8983 --network dev_network --name solr_app --mount source=solr-data,destination=/opt/solr/server/solr/nutch searchumd-solr:dev
```

The Solr container will now use and persist data in the "solr-data" Docker
volume. The Solr instance should now be available via a web browser at:

[http://localhost:8983/solr][solr]

## Docker Images

This application provides the following Dockerfiles for generating Docker images
for use in production:

* Dockerfile - Generates image for the searchumd Rails application
* Dockerfile-solr - Generates image for the Solr search application
* Dockerfile-nutch - Generates image for Apache Nutch application with UMD
    custom configuration

The "docker_config" directory contains files used by the Dockerfiles.

In order to generate "clean" Docker images, the Docker images should be
built from a fresh clone of the GitHub repository.

### Generating New Docker Images

The following steps can be done on any workstation (i.e., your MacBook):

#### 1) Update searchumd so that the "Gemfile.lock" file points to the latest commits of the searchers

This step is needed because we have not (yet) provided distinct version numbers
for the searchers, nor pushed up the searchers as Ruby gems into the Nexus. The
"Gemfile" of the "searchumd" application simply points to the "develop" branch
of each of the searchers, and as the searchers are updated, the "Gemfile.lock"
file in the "searchumd" application gets slowly out of date. The following steps
resets the "Gemfile.lock" to the latest commits for the searchers:

1.a) Create an empty directory for the checkout. For these steps, we'll use
     "/tmp/searchumd-build":

```
> mkdir /tmp/searchumd-build
```

1.b) Switch to the directory, and clone the "searchumd" application:

```
> cd /tmp/searchumd-build
> git clone https://github.com/umd-lib/searchumd.git
```

1.c) Switch into the "searchumd" directory, and update each of the searcher
     gems, as well as the "quick_search-core" and "umd_theme" gems:

```
> cd searchumd
> bundle update quick_search-core
> bundle update quick_search-archives_space_searcher
> bundle update quick_search-database_finder_searcher
> bundle update quick_search-drum_searcher
> bundle update quick_search-ebsco_discovery_service_api_searcher
> bundle update quick_search-fedora_searcher
> bundle update quick_search-internet_archive_searcher
> bundle update quick_search-lib_answers_searcher
> bundle update quick_search-lib_guides_searcher
> bundle update quick_search-library_website_searcher
> bundle update quick_search-maryland_map_searcher
> bundle update quick_search-world_cat_discovery_api_searcher
> bundle update umd_open_url
> bundle update quick_search-umd_theme
```

**Note:**  The above list was obtained by examining the "Gemfile", and looking
for gems having a "git" repository with a "develop" branch, for example:

```
gem 'quick_search-lib_answers_searcher',
    git: 'https://github.com/umd-lib/quick_search-lib_answers_searcher.git', branch: 'develop'
```

Be sure to examine the "Gemfile" to ensure that all the appropriate gems are updated.

An alternative to doing the above is to simply run "bundle update". This is
slightly more dangerous, as not all the gem dependencies are "pinned" to
specific versions, so there may be changes in gems unrelated to the searchers.
This might be okay, though, if only the "patch" version numbers are changed.

This issue should largely go away once we start versioning the searcher gems.

1.d) Examine the "Gemfile.lock" file:

```
> vi Gemfile.lock
```

and make sure that all the searchers, as well as the  "quick_search-core" and
"umd_theme" gems),  point to the latest commit of their respective repositories.

**Note:** There may also be additional dependencies that have been added, or
version updates to existing dependencies. These are likely okay, but should be
kept in mind if there are any issues.

1.e) Commit the changes to the "Gemfile.lock" file, and push up to GitHub:

```
> git add Gemfile.lock
> git commit
> git push origin develop
```

#### 2) Build the Docker images for the various components

Once the "searchumd" application is up to date, we need to build the Docker
images for each of the components. The current practice so far has been to
rebuild all the Docker images for each "release", even if nothing may have
changed with them. This is mainly done so that we don't have to track what's
changed in which image, and to provide a consistent "version number" for all
the images.

Until we actually start releasing actual version, the GIt branch and Git commit
hash of the "searchumd" application is used to identify the version of the
containers.

2.a) Copy the Git branch and commit into "GIT_BRANCH" and "GIT_COMMIT_HASH"
     environment variables:

```
> export GIT_BRANCH=`git rev-parse --abbrev-ref HEAD`
> export GIT_COMMIT_HASH=`git rev-parse HEAD`
```

to retrieve the Git commit hash of the latest commit.

2.b) Examine the the "GIT_BRANCH" and "GIT_COMMIT_HASH" values to verify that
they are what is expected (and because they will be used in future steps):

```
> echo ${GIT_BRANCH}-${GIT_COMMIT_HASH}
```

2.c) Build each of the Docker containers, using the "GIT_COMMIT_HASH"
     environment variable to set the version:

```
> docker build --no-cache -t docker.lib.umd.edu/searchumd:${GIT_BRANCH}-${GIT_COMMIT_HASH} -f Dockerfile .
> docker build --no-cache -t docker.lib.umd.edu/searchumd-nutch:${GIT_BRANCH}-${GIT_COMMIT_HASH} -f Dockerfile-nutch .
> docker build --no-cache -t docker.lib.umd.edu/searchumd-solr:${GIT_BRANCH}-${GIT_COMMIT_HASH} -f Dockerfile-solr .
```

**Note:** The "--no-cache" option is used to force Docker to download the
latest version of any images, instead of relying on whatever might be in the
cache on a particular workstation.

2.d) Push each of the images up to the private UMD docker registry:

```
> docker push docker.lib.umd.edu/searchumd:${GIT_BRANCH}-${GIT_COMMIT_HASH}
> docker push docker.lib.umd.edu/searchumd-nutch:${GIT_BRANCH}-${GIT_COMMIT_HASH}
> docker push docker.lib.umd.edu/searchumd-solr:${GIT_BRANCH}-${GIT_COMMIT_HASH}
```

## Additional Functionality

### Website search interface

In addition to the functionality provided by the NSCU QuickSearch Rails engine,
this application also provides a search page for the library website on the
"website" path (i.e., [http://localhost:3000/website][website].

This functionality uses the quick_search-library_website_searcher to generate
the results, and so is also dependent on a running Solr instance.

[quick_search]: https://github.com/NCSU-Libraries/quick_search
[umd_quick_search]: https://github.com/umd-lib/quick_search
[solr]: http://localhost:8983/
[website]: http://localhost:3000/website
[docker]: https://docs.docker.com/storage/volumes/#backup-restore-or-migrate-data-volumes
