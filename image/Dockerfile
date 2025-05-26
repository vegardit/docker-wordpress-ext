#syntax=docker/dockerfile:1
# see https://github.com/moby/buildkit/blob/master/frontend/dockerfile/docs/reference.md
# see https://docs.docker.com/engine/reference/builder/#syntax
#
# SPDX-FileCopyrightText: © Vegard IT GmbH (https://vegardit.com)
# SPDX-FileContributor: Sebastian Thomschke
# SPDX-License-Identifier: GPL-2.0-or-later
# SPDX-ArtifactOfProjectHomePage: https://github.com/vegardit/docker-wordpress-ext

# https://hub.docker.com/_/wordpress/tags?name=latest
ARG BASE_IMAGE=wordpress:latest

#############################################################
# build final image
#############################################################

# https://github.com/hadolint/hadolint/wiki/DL3006 Always tag the version of an image explicitly
# hadolint ignore=DL3006
FROM ${BASE_IMAGE} as final

ARG DEBIAN_FRONTEND=noninteractive
ARG LC_ALL=C

SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

ARG BASE_LAYER_CACHE_KEY
ARG INSTALL_SUPPORT_TOOLS=0

# https://github.com/hadolint/hadolint/wiki/DL3008 Pin versions
# hadolint ignore=DL3008
RUN --mount=type=bind,source=.shared,target=/mnt/shared <<EOF
  /mnt/shared/cmd/debian-install-os-updates.sh
  /mnt/shared/cmd/debian-install-support-tools.sh

  ARCH=$(dpkg --print-architecture)

  echo "#################################################"
  echo "$ARCH based image will be created"
  echo "#################################################"

  case "$ARCH" in
    amd64) LIB_ARCH="x86_64" ;;
    arm64) LIB_ARCH="aarch64" ;;
    *)     echo "Unknown architecture"; exit 1;;
  esac

  echo "#################################################"
  echo "Configuring LDAP client support..."
  echo "#################################################"
  apt-get install --no-install-recommends -y libldap2-dev
  docker-php-ext-configure ldap "--with-libdir=lib/${LIB_ARCH}-linux-gnu/"
  docker-php-ext-install ldap
  apt-get purge -y libldap2-dev

  echo "#################################################"
  echo "Configuring OPcache support..."
  echo "#################################################"
  docker-php-ext-install opcache

  echo "#################################################"
  echo "Enabling production ready php ini file..."
  echo "#################################################"
  ln -s "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

  echo "#################################################"
  echo "Extending docker-entrypoint.sh..."
  echo "#################################################"
  sed -i '/^exec "[$]@"/i source /usr/local/bin/docker-entrypoint-addons.sh' /usr/local/bin/docker-entrypoint.sh

  /mnt/shared/cmd/debian-cleanup.sh

EOF

COPY image/opcache.ini /usr/local/etc/php/conf.d/opcache.ini
COPY image/docker-entrypoint-addons.sh /usr/local/bin/

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

ARG OCI_authors
ARG OCI_title
ARG OCI_description
ARG OCI_source
ARG OCI_revision
ARG OCI_version
ARG OCI_created

ARG GIT_BRANCH
ARG GIT_COMMIT_DATE

# https://github.com/opencontainers/image-spec/blob/main/annotations.md
LABEL \
  org.opencontainers.image.title="$OCI_title" \
  org.opencontainers.image.description="$OCI_description" \
  org.opencontainers.image.source="$OCI_source" \
  org.opencontainers.image.revision="$OCI_revision" \
  org.opencontainers.image.version="$OCI_version" \
  org.opencontainers.image.created="$OCI_created"

LABEL maintainer="$OCI_authors"

RUN <<EOF
  echo "#################################################"
  echo "Writing build_info..."
  echo "#################################################"
  cat <<EOT >/opt/build_info
GIT_REPO:    $OCI_source
GIT_BRANCH:  $GIT_BRANCH
GIT_COMMIT:  $OCI_revision @ $GIT_COMMIT_DATE
IMAGE_BUILD: $OCI_created
EOT
  cat /opt/build_info

EOF
