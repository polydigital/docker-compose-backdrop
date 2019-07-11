# Docker and Docker Compose for Backdrop CMS #

[Backdrop CMS](https://backdropcms.org) started life as a supported
CMS to migrate to from Drupal 7.  The CMS has many improvements over
Drupal 7 from more recent development and should be easyu to migreate
current Drupal 7 sites.

The image the Dockerfile creates is built from the [Backdrop source](https://github.com/backdrop/backdrop)
and includes all dependencies required to create an image that can run
backdrop including all php extensions.

The Dockerfile is independent of docker-compose.yml though the
docker-compose.yml will create the necessary containers for the
database as well as the required volumes and environment variables.

Docker Compose creates 3 containers: backdrop, mariadb (mysql) and
phpmyadmin (included to assist development etc).  These containers
share a network called web.

## Backdrop versions and php.ini settings ##

Within the ```Dockerfile``` you can specify the version of Backdrop to
use, pulled from the [backdrop releases](https://github.com/backdrop/backdrop/releases).

Edit ```BACKDROP_VERSION``` variable to change the version -
currently this is set to the latest stable version 1.13.2

The php environment can be changed from development to production by
editing the ```BACKDROP_PHP_INI``` varible.  This is set to the
development ini so that php errors will be written to the docker
logs.  

When changing these values the image will need to be recreated using 

```
$ docker-compose build backdrop
```

## Setting up the network ##

First we have to manually set up the docker network they will run on:

```
$ docker network create web
```

## Setting the environment variables ##

The database credentials and ports for the containers on the localhost
are required to be set up.  We don't keep these in git of course so
we'll use a ```.env``` file.  The ```template.env``` file has the
variables so copy this and edit them.

```
$ cp template.env .env
```

Change these values in ```.env``` to your own database and web port
preferences and save the file.

```
BACKDROP_DB_HOST=my_backdrop_mysql_container
BACKDROP_DB_NAME=my_backdrop_db_name
BACKDROP_DB_PORT=3306
BACKDROP_DB_ROOT_PASSWORD=super_secret
BACKDROP_DB_USER=my_backdrop_db_username
BACKDROP_DB_USER_PASSWORD=another_secret
BACKDROP_PORT=80
BACKDROP_PHPMYADMIN_PORT=8080
```

## Creating and running the docker containers ##

Once all environment variables are set then you can create and run the
containers using docker compose.

```
$ docker-compose up -d
```

## Backdrop settings.php ##

The ```settings.php``` file is copied into the image when the image is
created.  The file has been modified from the backdrop cms standard
one to include setting up the database credentials via environment
variables.

This settings file also enables the utf8mb4 for mysql which is
recommended by backdrop CMS.  If interested you can [read more about this in the Backdrop docs](https://api.backdropcms.org/database-configuration).

### Adding more settings to backdrop ###

You may need to add more settings to backdrop as you use it.  You can
do this by editing this ```settings.php``` and then rebuilding the
image.

```
$ docker-compose build backdrop
```

## MYSQL Config ##

As mentioned above, the 4-byte UTF-8 character support has been
applied.  This is configured on the MYSQL side of things via the
```custom-mysql.conf``` file.

Other myslq config settings can be applied in this file too and the
service restarted.

It's important that the container can access this file so if you are
going to remove this dir from the host machine then copy the file to
another location and update the path ```-
./custom-mysql.conf:/etc/mysql/conf.d/custom.cnf``` in the
docker-compose.yml file and restart the container using
docker-compose.


## Removing the containers ##

```
$ docker-compose down
```

will stop the containers and remove them.

## Volumes and persisting data ##

The database data and the backdrop files are stored on the host
machine. This means you can easily create backups and
stop/start/recreate containers without loosing the data.

### Backdrop directories ###

  * files: ```/srv/www/backdrop/html/files```
    * The configs and site files are stored here
	* apache has write access to this folder
	* the files here are largely set up on installation
  * sites: ```/srv/www/backdrop/html/sites```
    * This dir is used for [multisite configuration](https://github.com/backdrop/backdrop/tree/1.x/sites)
  * layouts: ```/srv/www/backdrop/html/layouts```
    * bespoke layouts can be added for different content regions
	* [Read about layouts in the backdrop docs](https://backdropcms.org/layouts)
  * modules: ```/srv/www/backdrop/html/modules```
    * [dir to add downloaded modules to](https://backdropcms.org/modules)
	  

### Mysql data directory ###

The MySQL data will be stored in ```/srv/data/backdrop-db/```

