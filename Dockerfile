# ==============================================================================
# ETAPA 1: Descarga del drop-in PostgreSQL para WordPress (Builder - Debian)
# ==============================================================================
FROM debian:bookworm-slim AS downloader

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates curl unzip && \
    rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://github.com/kevinoid/postgresql-for-wordpress/archive/refs/heads/master.zip -o /tmp/pg4wp.zip && \
    unzip -q /tmp/pg4wp.zip -d /tmp/ && \
    mv /tmp/postgresql-for-wordpress-master/pg4wp /tmp/pg4wp_final && \
    rm -f /tmp/pg4wp.zip

# ==============================================================================
# ETAPA 2: Imagen final de producción (oficial WordPress, Debian + Apache)
# ==============================================================================
FROM wordpress:7.1.0-php8.3-apache AS runner

ENV WP_ENVIRONMENT_TYPE=production \
    PHP_INI_DIR=/usr/local/etc/php

# Extensiones pgsql/pdo_pgsql: libpq-dev solo se necesita para compilar,
# se purga en la misma capa para no dejar cabeceras de compilación en la imagen final.
RUN apt-get update && \
    apt-get install -y --no-install-recommends libpq-dev && \
    docker-php-ext-install pgsql pdo_pgsql && \
    apt-get purge -y --auto-remove libpq-dev && \
    rm -rf /var/lib/apt/lists/*

# Drop-in de base de datos: hace que wpdb hable con PostgreSQL en vez de MySQL
COPY --from=downloader --chown=www-data:www-data /tmp/pg4wp_final /usr/src/wordpress/wp-content/pg4wp
RUN cp /usr/src/wordpress/wp-content/pg4wp/db.php /usr/src/wordpress/wp-content/db.php && \
    chown www-data:www-data /usr/src/wordpress/wp-content/db.php

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
