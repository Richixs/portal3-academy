# ==============================================================================
# Imagen final de producción (oficial WordPress, Debian + Apache, MySQL/MariaDB)
# ==============================================================================
FROM wordpress:7.1.0-php8.3-apache AS runner

ENV WP_ENVIRONMENT_TYPE=production \
    PHP_INI_DIR=/usr/local/etc/php

# Plugins y temas del proyecto (incluye el submódulo unlock-wordpress-plugin en src/plugins/)
COPY --chown=www-data:www-data src/plugins/ /usr/src/wordpress/wp-content/plugins/
COPY --chown=www-data:www-data src/themes/ /usr/src/wordpress/wp-content/themes/

# opcache.validate_timestamps=0: la imagen es inmutable por build, así que no hace
# falta que PHP revise el mtime de cada archivo en cada request (gana rendimiento).
RUN { \
        echo 'opcache.enable=1'; \
        echo 'opcache.memory_consumption=128'; \
        echo 'opcache.interned_strings_buffer=8'; \
        echo 'opcache.max_accelerated_files=10000'; \
        echo 'opcache.validate_timestamps=0'; \
        echo 'opcache.fast_shutdown=1'; \
        echo 'opcache.save_comments=1'; \
    } > $PHP_INI_DIR/conf.d/opcache-recommended.ini && \
    { \
        echo 'upload_max_filesize=64M'; \
        echo 'post_max_size=64M'; \
        echo 'memory_limit=256M'; \
        echo 'max_execution_time=300'; \
        echo 'expose_php=Off'; \
        echo 'display_errors=Off'; \
        echo 'log_errors=On'; \
    } > $PHP_INI_DIR/conf.d/wordpress-production.ini

EXPOSE 80

WORKDIR /var/www/html
