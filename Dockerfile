FROM php:7.3.6-apache-stretch
LABEL maintainer="Tom Broughton <docker@tombroughton.me>"

# see https://github.com/backdrop/backdrop/releases
ARG BACKDROP_VERSION=1.13.2

# this could be set to php.ini-production or php.ini-development
ARG BACKDROP_PHP_INI="php.ini-development"

# install requirements for this Dockerfile
# and from https://backdropcms.org/requirements
# and from the initialisation/install.php
RUN apt-get update && \
    apt-get install -y curl \
             mysql-client \
	     libpng-dev \
	     libjpeg-dev
	     
RUN docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr

RUN docker-php-ext-install \
    mbstring \
    pdo \
    pdo_mysql \
    gd

RUN a2enmod rewrite

# enable relevant php ini, developer useful for errors in logs etc
RUN echo "Setting up php.ini based on ${BACDROP_PHP_INI}" && \
    cp /usr/local/etc/php/"${BACKDROP_PHP_INI}" /usr/local/etc/php/php.ini

# download release of backdrop and unpack to apache directories
RUN echo "Getting version: ${BACKDROP_VERSION}" && \
        curl \
                --location \
                --fail \
                --silent \
                --show-error \
                --output /opt/backdrop.tar.gz \
               https://github.com/backdrop/backdrop/archive/"${BACKDROP_VERSION}".tar.gz && \
        tar xf /opt/backdrop.tar.gz \
                --directory /var/www/html \
                --strip-components=1 && \
        rm /opt/backdrop.tar.gz

# make a copy of the files dir (really it's only the .htaccess that matters at this time)
RUN cp -R /var/www/html/files/ /var/www/html/files-core/

# ensure out apache users are the correct ones
ENV APACHE_RUN_USER=www-data
ENV APACHE_RUN_GROUP=www-data

# Copy the custom settings file, if present. The configuration file has to
# be manually put inside the same directory containing the Dockerfile (we cannot
# directly point to "../settings.php" for Docker's security restrictions).
#
# For the conditional COPY trick, see:
#   https://stackoverflow.com/questions/31528384/conditional-copy-add-in-dockerfile#4680
COPY nop settings.php /var/www/html/

# the internal port backdrop is accessed
EXPOSE 80

# get the entrypoint.sh into the image and make sure it's executable
COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]

