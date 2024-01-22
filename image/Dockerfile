#syntax=docker/dockerfile:1.2
# SPDX-FileCopyrightText: © Vegard IT GmbH (https://vegardit.com)
# SPDX-FileContributor: Sebastian Thomschke
# SPDX-License-Identifier: GPL-2.0-or-later
# SPDX-ArtifactOfProjectHomePage: https://github.com/vegardit/docker-wordpress-ext

# https://hub.docker.com/_/wordpress/tags?name=latest
ARG BASE_IMAGE=wordpress:latest

FROM ${BASE_IMAGE}

LABEL maintainer="Vegard IT GmbH (vegardit.com)"

USER root

SHELL ["/bin/bash", "-c"]

ARG DEBIAN_FRONTEND=noninteractive
ARG LC_ALL=C

ARG BASE_LAYER_CACHE_KEY
ARG INSTALL_SUPPORT_TOOLS=0

RUN --mount=type=bind,source=.shared,target=/mnt/shared \
  set -eu && \
  /mnt/shared/cmd/debian-install-os-updates.sh && \
  /mnt/shared/cmd/debian-install-support-tools.sh && \
 #
  echo "#################################################" && \
  echo "Configuring LDAP client support..." && \
  echo "#################################################" && \
  apt-get install -y libldap2-dev && \
  docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ && \
  docker-php-ext-install ldap && \
  apt-get purge -y libldap2-dev && \
  #
  echo "#################################################" && \
  echo "Configuring OPcache support..." && \
  echo "#################################################" && \
  docker-php-ext-install opcache && \
  #
  echo "#################################################" && \
  echo "Enabling production ready php ini file..." && \
  echo "#################################################" && \
  ln -s "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" && \
  #
  echo "#################################################" && \
  echo "Extending docker-entrypoint.sh..." && \
  echo "#################################################" && \
  sed -i '/^exec "[$]@"/i source /usr/local/bin/docker-entrypoint-addons.sh' /usr/local/bin/docker-entrypoint.sh && \
  #
  /mnt/shared/cmd/debian-cleanup.sh

ARG BUILD_DATE
ARG GIT_BRANCH
ARG GIT_COMMIT_HASH
ARG GIT_COMMIT_DATE
ARG GIT_REPO_URL

LABEL \
  org.label-schema.schema-version="1.0" \
  org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.vcs-ref=$GIT_COMMIT_HASH \
  org.label-schema.vcs-url=$GIT_REPO_URL


# Default configuration: can be overridden at the docker command line
ENV \
  INIT_SH_FILE='' \
  # See https://www.php.net/manual/en/opcache.configuration.php
  PHP_OPCACHE_ENABLE="1" \
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

COPY image/opcache.ini /usr/local/etc/php/conf.d/opcache.ini
COPY image/docker-entrypoint-addons.sh /usr/local/bin/

RUN \
  set -eu && \
  echo -e "\
GIT_REPO:    $GIT_REPO_URL\n\
GIT_BRANCH:  $GIT_BRANCH\n\
GIT_COMMIT:  $GIT_COMMIT_HASH @ $GIT_COMMIT_DATE\n\
IMAGE_BUILD: $BUILD_DATE\n" >/opt/build_info
