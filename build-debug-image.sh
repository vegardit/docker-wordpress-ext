#!/usr/bin/env bash
#
# Copyright 2020 by Vegard IT GmbH, Germany, https://vegardit.com
# SPDX-License-Identifier: SPDX-License-Identifier: GPL-2.0-or-later
#
# Author: Sebastian Thomschke, Vegard IT GmbH
#
# https://github.com/vegardit/docker-wordpress-ext
#

bash "$(dirname "$0")/build-image.sh" --build-arg DEBUG_BUILD=1
