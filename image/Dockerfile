# Copyright 2020 by Vegard IT GmbH, Germany, https://vegardit.com
# SPDX-License-Identifier: SPDX-License-Identifier: GPL-2.0-or-later
#
# Author: Sebastian Thomschke, Vegard IT GmbH
#
# https://github.com/vegardit/docker-wordpress-ext
#

# https://hub.docker.com/_/wordpress?tab=tags&name=latest
ARG BASE_IMAGE=wordpress:latest

FROM ${BASE_IMAGE}

LABEL maintainer="Vegard IT GmbH (vegardit.com)"

USER root

SHELL ["/bin/bash", "-c"]

# if set to 1 debug tools are added to the image (htop,less,mc,vim)
ARG DEBUG_BUILD=0

ARG DEBIAN_FRONTEND=noninteractive
ARG LC_ALL=C

ARG BASE_LAYER_CACHE_KEY

RUN \
  set -eu && \
  echo "#################################################" && \
  echo "Installing OS updates..." && \
  echo "#################################################" && \
  apt-get update -y && \
  # https://github.com/phusion/baseimage-docker/issues/319
  apt-get install --no-install-recommends -y apt-utils 2> >( grep -v 'debconf: delaying package configuration, since apt-utils is not installed' >&2 ) && \
  apt-get upgrade -y && \
  #
  if [ "${DEBUG_BUILD}" = "1" ]; then \
     echo "#################################################" && \
     echo "Installing debugging tools..." && \
     echo "#################################################" && \
     apt-get install --no-install-recommends -y libcomerr2 mc && \
     apt-get install --no-install-recommends -y htop less procps vim && \
     echo -e 'set ignorecase\n\
set showmatch\n\
set novisualbell\n\
set noerrorbells\n\
syntax enable\n\
set mouse-=a' > ~/.vimrc; \
  fi && \
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
  echo "#################################################" && \
  echo "apt-get clean up..." && \
  echo "#################################################" && \
  apt-get remove apt-utils -y && \
  apt-get clean autoclean && \
  apt-get autoremove --purge -y && \
  #
  echo "#################################################" && \
  echo "Removing logs, caches and temp files..." && \
  echo "#################################################" && \
  rm -rf /var/cache/{apt,debconf} \
     /var/lib/apt/lists/* \
     /var/log/{apt,alternatives.log,bootstrap.log,dpkg.log} \
     /tmp/* /var/tmp/*

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

ENV  \
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

COPY opcache.ini /usr/local/etc/php/conf.d/opcache.ini
COPY docker-entrypoint-addons.sh /usr/local/bin/

RUN \
  echo "GIT_REPO:   $GIT_REPO_URL" > /opt/build_info && \
  echo "GIT_BRANCH: $GIT_BRANCH" >> /opt/build_info && \
  echo "GIT_COMMIT: $GIT_COMMIT_HASH @ $GIT_COMMIT_DATE" >> /opt/build_info  && \
  echo "IMAGE_BUILD: $BUILD_DATE" >> /opt/build_info && \
  cat /opt/build_info
