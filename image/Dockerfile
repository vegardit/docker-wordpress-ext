# Copyright 2020 by Vegard IT GmbH, Germany, https://vegardit.com
# SPDX-License-Identifier: SPDX-License-Identifier: GPL-2.0-or-later
#
# @author Sebastian Thomschke, Vegard IT GmbH
#
# https://github.com/vegardit/docker-wordpress-ext
#
FROM wordpress:latest

ARG BUILD_DATE
ARG GIT_REPO_URL
ARG GIT_COMMIT_HASH

LABEL \
  org.label-schema.schema-version="1.0" \
  org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.vcs-ref=$GIT_COMMIT_HASH \
  org.label-schema.vcs-url=$GIT_REPO_URL

RUN set -x && \
  apt-get update && \
  ############################################################
  echo "Configuring LDAP client support..." && \
  apt-get install -y libldap2-dev && \
  docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ && \
  docker-php-ext-install ldap && \
  apt-get purge -y libldap2-dev && \
  ############################################################
  echo "Configuring opcache support..." && \
  docker-php-ext-install opcache && \
  # Use production ready php ini file
  ln -s "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" && \
  ############################################################
  echo "apt-get clean up..." && \
  apt-get clean autoclean && \
  apt-get autoremove --purge -y && \
  ############################################################
  echo "Extending docker-entrypoint.sh..." && \
  sed -i '/^exec "[$]@"/i source /usr/local/bin/docker-entrypoint-addons.sh' /usr/local/bin/docker-entrypoint.sh && \
  ############################################################
  echo "Removing logs, caches and temp files..." && \
  rm -rf /var/cache/{apt,debconf} \
     /var/lib/apt/lists/* \
     /var/log/{apt,alternatives.log,dpkg.log} \
     /tmp/* /var/tmp/*

# See https://www.php.net/manual/en/opcache.configuration.php
ENV PHP_OPCACHE_ENABLE="1" \
    PHP_OPCACHE_INTERNED_STRINGS_BUFFER="8" \
    PHP_OPCACHE_LOG_VERBOSITY_LEVEL="1" \
    PHP_OPCACHE_MAX_ACCELERATED_FILES="10000" \
    PHP_OPCACHE_MAX_WASTED_PERCENTAGE="5" \
    PHP_OPCACHE_MEMORY_CONSUMPTION="128" \
    PHP_OPCACHE_REVALIDATE_FREQ="2" \
    PHP_OPCACHE_VALIDATE_TIMESTAMPS="1" \
    WP_REVERSE_HTTPS_PROXY="false" \
    WP_FORCE_SSL_ADMIN="false" \
    WP_FORCE_SSL_LOGIN="false"

COPY opcache.ini /usr/local/etc/php/conf.d/opcache.ini
COPY docker-entrypoint-addons.sh /usr/local/bin/
