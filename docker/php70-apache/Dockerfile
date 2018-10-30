FROM php:7.0-apache

# Installs php extensions
RUN apt-get update \
  && apt-get install -y \
      git \
      vim \
      wget \
      apt-utils \
      locales \
      libfreetype6-dev \
      libjpeg62-turbo-dev \
      libmcrypt-dev \
      mysql-client \
      libcurl3 \
      libcurl3-dev \
      libxml2-dev \
      libicu-dev \
      zlib1g-dev \
  && apt-get clean \
  && rm -r /var/lib/apt/lists/* \
  && rm -rf /tmp/pear

RUN docker-php-ext-install bcmath mcrypt gd curl pdo_mysql mbstring mysqli soap opcache intl zip sockets
RUN pecl install xdebug \
    && docker-php-ext-enable xdebug
RUN pecl install apcu \
    && docker-php-ext-enable apcu

# Composer
RUN curl -sS https://getcomposer.org/installer | php -- --filename=composer --install-dir=/usr/local/bin \
    && composer global require "hirak/prestissimo:^0.3"

# Configuration
RUN a2enmod rewrite ssl headers

COPY vhost.conf /etc/apache2/sites-available/000-default.conf
COPY php.ini /usr/local/etc/php/php.ini
COPY run.sh /usr/local/bin/run.sh

# Self signed certificates
COPY certs/api.docker.crt /etc/ssl/certs/api.docker.crt
COPY certs/api.docker.key /etc/ssl/private/api.docker.key

RUN chmod 440 /etc/ssl/certs/api.docker.crt
RUN chmod 440 /etc/ssl/private/api.docker.key

# Add www-data to root group and viceversa
RUN usermod -u 1000 www-data

# Change ownership of www-data root directory
RUN chown -R www-data:www-data /var/www

# Custom PHP ini configuration
COPY php.ini /usr/local/etc/php/conf.d/

#GOSU
# COPY install-gosu.sh /usr/local/bin/install-gosu.sh
# ENV GOSU_VERSION 1.10
# RUN install-gosu.sh

WORKDIR /var/www/app

# Start!
COPY ./run.sh /

ENTRYPOINT ["/run.sh"]
CMD ["apache2-foreground"]
