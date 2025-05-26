# vegardit/wordpress-ext <a href="https://github.com/vegardit/docker-wordpress-ext/" title="GitHub Repo"><img height="30" src="https://raw.githubusercontent.com/simple-icons/simple-icons/develop/icons/github.svg?sanitize=true"></a>

[![Build Status](https://github.com/vegardit/docker-wordpress-ext/workflows/Build/badge.svg "GitHub Actions")](https://github.com/vegardit/docker-wordpress-ext/actions?query=workflow%3ABuild)
[![License](https://img.shields.io/github/license/vegardit/docker-wordpress-ext.svg?label=license)](#license)
[![Docker Pulls](https://img.shields.io/docker/pulls/vegardit/wordpress-ext.svg)](https://hub.docker.com/r/vegardit/wordpress-ext)
[![Docker Stars](https://img.shields.io/docker/stars/vegardit/wordpress-ext.svg)](https://hub.docker.com/r/vegardit/wordpress-ext)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-v2.1%20adopted-ff69b4.svg)](CODE_OF_CONDUCT.md)

1. [What is it?](#what-is-it)
1. [License](#license)


## <a name="what-is-it"></a>What is it?

This docker image extends the official [Wordpress](https://wordpress.org) docker image [`wordpress:latest`](https://hub.docker.com/_/wordpress/?tab=tags&name=latest) with additional support for [LDAP auth](https://www.php.net/manual/en/book.ldap.php), [OPcache](https://www.php.net/manual/en/book.opcache.php) and reverse HTTPS proxies.

It is automatically built **daily** to include the latest OS security fixes.

1. Adds [PHP LDAP](https://www.php.net/manual/en/book.ldap.php) client support.
1. Enables the [php-production.ini](https://github.com/php/php-src/blob/master/php.ini-production) configuration.
1. Adds [OPcache](https://www.php.net/manual/en/book.opcache.php), wich can be configured via the following environment variables:
   ```bash
   PHP_OPCACHE_ENABLE="1"                     # Enables the opcode cache
   PHP_OPCACHE_INTERNED_STRINGS_BUFFER="8"    # Amount of memory used to store interned strings, in MB.
   PHP_OPCACHE_LOG_VERBOSITY_LEVEL="1"        # The log verbosity level. 0 to 4
   PHP_OPCACHE_MAX_ACCELERATED_FILES="10000"
   PHP_OPCACHE_MAX_WASTED_PERCENTAGE="5"      # The max. percentage of wasted memory before a restart is scheduled.
   PHP_OPCACHE_MEMORY_CONSUMPTION="128"       # Shared memory storage used, in MB.
   PHP_OPCACHE_REVALIDATE_FREQ="2"
   PHP_OPCACHE_VALIDATE_TIMESTAMPS="1"        # If enabled, checks for updated scripts every $PHP_OPCACHE_REVALIDATE_FREQ seconds.
   ```

1. Configures force HTTPS Login / Admin UI via environment variables:
   ```bash
   WP_FORCE_SSL_LOGIN="true" # default is "false"
   WP_FORCE_SSL_ADMIN="true" # default is "false"
   ```
   See https://wordpress.org/support/article/administration-over-ssl/

1. Enables support for reverse proxies (e.g. [Traefik](https://containo.us/traefik/)) via environment variable
   ```bash
   WP_REVERSE_HTTPS_PROXY="true" # default is "false"
   ```
   See https://wordpress.org/support/article/administration-over-ssl/#using-a-reverse-proxy


## <a name="license"></a>License

All files in this repository are released under the [GNU General Public License v2.0 or later](LICENSE.txt).

Individual files contain the following tag instead of the full license text:
```
SPDX-License-Identifier: GPL-2.0-or-later
```

This enables machine processing of license information based on the SPDX License Identifiers that are available here: https://spdx.org/licenses/.