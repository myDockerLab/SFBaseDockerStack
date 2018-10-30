FROM bitnami/php-fpm

RUN usermod -u 1000 www-data
RUN usermod -G staff www-data

# Add www-data to root group and viceversa
#RUN usermod -u 1000 www-data

# Change ownership of www-data root directory
#RUNs chown -R www-data:www-data /srv/api