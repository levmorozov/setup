#!/usr/bin/env bash

wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php7.4.list

apt update
apt install -y php7.4 php7.4-fpm php7.4-dev php7.4-gd php7.4-curl php-pear \
                php-apcu php7.4-intl php7.4-xml php7.4-zip php7.4-mbstring php7.4-mysql

EXPECTED_SIGNATURE="$(wget -q -O - https://composer.github.io/installer.sig)"
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
ACTUAL_SIGNATURE="$(php -r "echo hash_file('SHA384', 'composer-setup.php');")"

if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]
then
    >&2 echo 'ERROR: Invalid installer signature'
    rm composer-setup.php
    exit 1
fi

php composer-setup.php --quiet
mv composer.phar /usr/local/bin/composer
rm composer-setup.php

cat <<EOF > /etc/php/7.4/fpm/conf.d/30-xcvb.ini
memory_limit = 128M
upload_max_filesize = 15M
post_max_size = 15M
realpath_cache_size = 128k
realpath_cache_ttl =  3600
expose_php = Off
session.use_strict_mode = 1
opcache.memory_consumption = 42
opcache.validate_timestamps = 0
opcache.enable_file_override = 1
opcache.save_comments = 0
opcache.interned_strings_buffer=4

date.timezone = 'Europe/Moscow'
mysqlnd.collect_statistics = Off
session.cookie_samesite = Lax
EOF

cat <<EOF > /etc/php/7.4/cli/conf.d/30-xcvb.ini
date.timezone = 'Europe/Moscow'
EOF
