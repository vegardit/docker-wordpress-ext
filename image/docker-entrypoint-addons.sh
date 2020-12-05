#!/bin/bash
#
# Copyright 2020 by Vegard IT GmbH, Germany, https://vegardit.com
# SPDX-License-Identifier: SPDX-License-Identifier: GPL-2.0-or-later
#
# Author: Sebastian Thomschke, Vegard IT GmbH
#
# https://github.com/vegardit/docker-wordpress-ext
#

# This file will be sourced by /usr/local/bin/docker-entrypoint.sh

cat <<'EOF'
 _    __                          __   __________
| |  / /__  ____ _____ __________/ /  /  _/_  __/
| | / / _ \/ __ `/ __ `/ ___/ __  /   / /  / /
| |/ /  __/ /_/ / /_/ / /  / /_/ /  _/ /  / /
|___/\___/\__, /\__,_/_/   \__,_/  /___/ /_/
         /____/

EOF

cat /opt/build_info
echo

if [ -f "$INIT_SH_FILE" ]; then
   source "$INIT_SH_FILE"
fi


value="define('FORCE_SSL_LOGIN', $WP_FORCE_SSL_LOGIN);"
echo "Setting $value..."
if grep -q "define('FORCE_SSL_LOGIN', .*);" wp-config.php; then
  sed -i "s/define('FORCE_SSL_LOGIN', .*);/$value/" wp-config.php # replace
else
  sed -i "0,/^define(.*/s/^define(.*/$value\n&/" wp-config.php # insert before first occurence of "define(..."
fi

value="define('FORCE_SSL_ADMIN', $WP_FORCE_SSL_ADMIN);"
echo "Setting $value..."
if grep -q "define('FORCE_SSL_ADMIN', .*);" wp-config.php; then
  sed -i "s/define('FORCE_SSL_ADMIN', .*);/$value/" wp-config.php # replace
else
  sed -i "0,/^define(.*/s/^define(.*/$value\n&/" wp-config.php # insert before first occurence of "define(..."
fi

if [[ $WP_REVERSE_HTTPS_PROXY == "true" || $WP_REVERSE_HTTPS_PROXY == "1" ]]; then
  echo "Enabling reverse proxy support..."
  if ! grep -q "\$_SERVER\['HTTP_X_FORWARDED_PROTO'\]" wp-config.php; then
    value="if (\$_SERVER['HTTP_X_FORWARDED_PROTO'] == 'https') \$_SERVER['HTTPS']='on';"
    sed -i "0,/^define(.*/s/^define(.*/$value\n&/" wp-config.php # insert before first occurence of "define(..."
  fi
  if ! grep -q "\$_SERVER\['HTTP_X_FORWARDED_HOST'\]" wp-config.php; then
    value="if (isset(\$_SERVER['HTTP_X_FORWARDED_HOST'])) \$_SERVER['HTTP_HOST'] = \$_SERVER['HTTP_X_FORWARDED_HOST'];"
    sed -i "0,/^define(.*/s/^define(.*/$value\n&/" wp-config.php # insert before first occurence of "define(..."
  fi
  if ! grep -q "\$_SERVER\['HTTP_X_FORWARDED_FOR'\]" wp-config.php; then
    value="if (isset(\$_SERVER['HTTP_X_FORWARDED_FOR'])) \$_SERVER['REMOTE_ADDR'] = trim(end(explode(',', \$_SERVER['HTTP_X_FORWARDED_FOR'])));"
    sed -i "0,/^define(.*/s/^define(.*/$value\n&/" wp-config.php # insert before first occurence of "define(..."
  fi
else
  echo "Disabling reverse proxy support..."
  sed -i '/HTTP_X_FORWARDED_PROTO/d' wp-config.php
  sed -i '/HTTP_X_FORWARDED_HOST/d' wp-config.php
  sed -i '/HTTP_X_FORWARDED_FOR/d' wp-config.php
fi
