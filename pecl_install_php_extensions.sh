#!/bin/bash


if [[ ! "$(command -v pecl)" ]]; then
    echo "pear is not installed! Please install pear first!"
    exit 0
fi

### fix PHP Fatal error: Cannot use result of built-in function in write context in /usr/share/php/Archive/Tar.php on line 639
### https://www.dotkernel.com/php-troubleshooting/fix-installing-pear-packages-with-php-7-2/
sed -i 's/& func_get_args/func_get_args/' /usr/share/php/Archive/Tar.php # && pear install Archive_Tar
### fix Warning: Invalid argument supplied for foreach() in Command.php on line 249
sed -i 's/exec $PHP -C -n -q/exec $PHP -C -q/' /usr/bin/pecl

## pecl install imagick memcached mongodb oauth xdebug
apt install -y libmagickwand-dev libmemcached-dev zlib1g-dev --no-install-recommends && \
    cd /tmp && \
    curl -SL http://pecl.php.net/get/imagick -o imagick.tgz && \
    curl -SL http://pecl.php.net/get/memcached -o memcached.tgz && \
    curl -SL http://pecl.php.net/get/mongodb -o mongodb.tgz && \
    curl -SL http://pecl.php.net/get/redis -o redis.tgz && \
    curl -SL http://pecl.php.net/get/oauth -o oauth.tgz && \
    curl -SL http://pecl.php.net/get/xdebug -o xdebug.tgz && \
    printf "\n" | pecl install imagick.tgz && \
    printf "\n" | pecl install memcached.tgz && \
    printf "\n" | pecl install mongodb.tgz && \
    printf "\n" | pecl install redis.tgz && \
    printf "\n" | pecl install oauth.tgz && \
    printf "\n" | pecl install xdebug.tgz && \
    echo 'extension=imagick.so' > /etc/php/7.2/cli/conf.d/90-imagick.ini && \
    echo 'extension=memcached.so' > /etc/php/7.2/cli/conf.d/90-memcached.ini && \
    echo 'extension=mongodb.so' > /etc/php/7.2/cli/conf.d/90-mongodb.ini && \
    echo 'extension=redis.so' > /etc/php/7.2/cli/conf.d/90-redis.ini && \
    echo 'extension=oauth.so' > /etc/php/7.2/cli/conf.d/90-oauth.ini && \
    echo 'zend_extension=/usr/lib/php/20170718/xdebug.so' > /etc/php/7.2/cli/conf.d/90-xdebug.ini && \
    rm -rf /tmp/* && cd ~

## Install swoole
## https://github.com/swoole/swoole-src
## hiredis( for swoole )
## https://github.com/redis/hiredis
apt install -y libpq-dev nghttp2 libnghttp2-dev --no-install-recommends && \
    mkdir -p /tmp/downloads && cd /tmp && \
    curl -o ./downloads/hiredis.tar.gz https://github.com/redis/hiredis/archive/master.tar.gz -L && \
    tar zxvf ./downloads/hiredis.tar.gz && \
    mv hiredis* hiredis && cd hiredis && \
    make -j && make install && ldconfig && \
    cd /tmp && \
    curl -o ./downloads/swoole.tar.gz https://github.com/swoole/swoole-src/archive/master.tar.gz -L && \
    tar zxvf ./downloads/swoole.tar.gz && \
    mv swoole-src* swoole-src && cd swoole-src && \
    phpize && \
    ./configure \
        --enable-openssl \
        --enable-http2  \
        --enable-async-redis \
        --enable-sockets \
        --enable-mysqlnd \
        --enable-coroutine-postgresql && \
    make clean && make && make install && \
    echo 'extension=swoole.so' > /etc/php/7.2/cli/conf.d/90-swoole.ini && \
    rm -rf /tmp/*
