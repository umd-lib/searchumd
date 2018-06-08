# SearchUMD

## Introduction

UMD Libraries bento-box search application, based on the NSCU Quick Search
Rails engine ([https://github.com/NCSU-Libraries/quick_search][quick_search])

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
* Dockerfile-nginx - Generates image for the Nginx web server providing HTTPS
    and port redirection.
* Dockerfile-solr - Generates image for the Solr search application
* Dockerfile-nutch - Generates image for Apache Nutch application with UMD
    custom configuration

The "docker_config" directory contains files used by the Dockerfiles.

In order to generate "clean" Docker images, the Docker images should be
built from a fresh clone of the GitHub repository.

## Additional Functionality

### Website search interface

In addition to the functionality provided by the NSCU Quick Search Rails engine,
this application also provides a search page for the library website on the
"website" path (i.e., [http://localhost:3000/website][website].

This functionality uses the quick_search-library_website_searcher to generate
the results, and so is also dependent on a running Solr instance.

[quick_search]: https://github.com/NCSU-Libraries/quick_search
[solr]: http://localhost:8983/
[website]: http://localhost:3000/website
[docker]: https://docs.docker.com/storage/volumes/#backup-restore-or-migrate-data-volumes
