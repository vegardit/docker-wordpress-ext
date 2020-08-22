#!/usr/bin/env bash
#
# Copyright 2020 by Vegard IT GmbH, Germany, https://vegardit.com
# SPDX-License-Identifier: SPDX-License-Identifier: GPL-2.0-or-later
#
# @author Sebastian Thomschke, Vegard IT GmbH
#
# https://github.com/vegardit/docker-wordpress-ext
#

set -e -x
if [ ! -n "$BASH" ]; then /usr/bin/env bash "$0" "$@"; exit; fi

DOCKER_REGISTRY=${DOCKER_REGISTRY:-docker.io}
DOCKER_REPO=${DOCKER_REPO:-vegardit/wordpress-ext}

#
# determine PHP version and apply tags
#
php_version=$(docker run wordpress:latest php -v | grep -oP 'PHP \K\d+\.\d+')

echo "Building Wordpress image with PHP $php_version..."

docker build $(dirname $0)/image \
   --compress \
   --build-arg BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ") \
   --build-arg GIT_COMMIT_HASH="$(git rev-parse --short HEAD)" \
   --build-arg GIT_REPO_URL="$(git config --get remote.origin.url)" \
   -t $DOCKER_REPO:latest
  "$@"

#
# push image with tags to remote docker registry
#
if [[ "${DOCKER_PUSH:-0}" == "1" ]]; then
   docker push $DOCKER_REGISTRY/$DOCKER_REPO:latest
fi
