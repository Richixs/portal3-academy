# ==============================================================================
# ETAPA: build de assets del plugin unlock-wordpress-plugin (JS/CSS vía
# @wordpress/scripts). La raíz del submódulo solo trae las herramientas de
# build; el plugin real que WordPress necesita vive en el subdirectorio
# unlock-wordpress-plugin/unlock-wordpress-plugin/.
# ==============================================================================
FROM node:16-bookworm-slim AS plugin-builder

# Fija Yarn classic 1.x (coincide con el yarn.lock del submódulo) en vez de
# dejar que corepack resuelva a la última versión (Berry), que reescribe el
# lockfile a un formato distinto.
RUN corepack enable && corepack prepare yarn@1.22.22 --activate

WORKDIR /plugin

COPY src/plugins/unlock-wordpress-plugin/package.json src/plugins/unlock-wordpress-plugin/yarn.lock ./
RUN yarn install --frozen-lockfile

COPY src/plugins/unlock-wordpress-plugin/ ./
RUN yarn build && yarn build:admin && yarn build:blocks

# ==============================================================================
# Imagen final de producción (oficial WordPress, Debian + Apache, MySQL/MariaDB)
# ==============================================================================
FROM wordpress:7.1.0-php8.3-apache AS runner

ENV WP_ENVIRONMENT_TYPE=production \
    PHP_INI_DIR=/usr/local/etc/php

# Se copia solo la carpeta real del plugin (unlock-wordpress-plugin/unlock-wordpress-plugin/),
# ya con los assets compilados por la etapa plugin-builder, para que WordPress
# la reconozca como plugin instalado en wp-content/plugins/.
COPY --from=plugin-builder --chown=www-data:www-data /plugin/unlock-wordpress-plugin/ /usr/src/wordpress/wp-content/plugins/unlock-wordpress-plugin/
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
