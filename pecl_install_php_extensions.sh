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

## Find PHP extension_dir
## php -ini | grep extension_dir
PHP_EXT_DIR=$(php-config --extension-dir)
PHP_INI_DIR=$(php --ini | grep "Scan for additional .ini files in" | cut -d':' -f2 | cut -d' ' -f2)

## pecl install imagick memcached mongodb oauth xdebug
## use proxy: curl -v --socks5-hostname 127.0.0.1:55880
apt install -y libmagickwand-dev libmemcached-dev zlib1g-dev --no-install-recommends && \
    cd /tmp && \
    curl -SL http://pecl.php.net/get/imagick -o imagick.tgz && \
    curl -SL http://pecl.php.net/get/memcached -o memcached.tgz && \
    curl -SL http://pecl.php.net/get/mongodb -o mongodb.tgz && \
    curl -SL http://pecl.php.net/get/oauth -o oauth.tgz && \
    curl -SL http://pecl.php.net/get/redis -o redis.tgz && \
    curl -SL http://pecl.php.net/get/xdebug -o xdebug.tgz && \
    printf "\n" | pecl install --force imagick.tgz && \
    printf "\n" | pecl install --force memcached.tgz && \
    printf "\n" | pecl install --force mongodb.tgz && \
    printf "\n" | pecl install --force oauth.tgz && \
    printf "\n" | pecl install --force redis.tgz && \
    printf "\n" | pecl install --force xdebug.tgz && \
    echo 'extension=imagick.so' > $PHP_INI_DIR/90-imagick.ini && \
    echo 'extension=memcached.so' > $PHP_INI_DIR/90-memcached.ini && \
    echo 'extension=mongodb.so' > $PHP_INI_DIR/90-mongodb.ini && \
    echo 'extension=oauth.so' > $PHP_INI_DIR/90-oauth.ini && \
    echo 'extension=redis.so' > $PHP_INI_DIR/90-redis.ini && \
    echo 'zend_extension=/usr/lib/php/20170718/xdebug.so' > $PHP_INI_DIR/90-xdebug.ini && \
    rm -rf /tmp/*

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
    echo 'extension=swoole.so' > $PHP_INI_DIR/90-swoole.ini && \
    rm -rf /tmp/*

## PDFlib
## https://www.pdflib.com/download/pdflib-product-family/
cd /tmp && \
    curl -o pdflib.tar.gz https://www.pdflib.com/binaries/PDFlib/912/PDFlib-9.1.2p1-Linux-x86_64-php.tar.gz -L && \
    tar -xvf pdflib.tar.gz && \
    mv PDFlib-* pdflib && cd pdflib && \
    cp bind/php/php-720-nts/php_pdflib.so $PHP_EXT_DIR && \
    echo 'extension=php_pdflib.so' > $PHP_INI_DIR/90-pdflib.ini && \
    rm -rf /tmp/*

## How to install OCI8
## https://gist.github.com/hewerthomn/81eea2935051eb2500941a9309bca703
## Download the Oracle Instant Client and SDK from Oracle website. (Need to login in Oracle page)
## http://www.oracle.com/technetwork/topics/linuxx86-64soft-092277.html
# mkdir -p /opt/oracle && cd /opt/oracle && \
#     unzip instantclient-basic-linux.x64-12.2.0.1.0.zip && \
#     unzip instantclient-sdk-linux.x64-12.2.0.1.0.zip && \
#     ln -s /opt/oracle/instantclient_12_2/libclntsh.so.12.1 /opt/oracle/instantclient_12_2/libclntsh.so && \
#     ln -s /opt/oracle/instantclient_12_2/libocci.so.12.1 /opt/oracle/instantclient_12_2/libocci.so && \
#     echo /opt/oracle/instantclient_12_2 > /etc/ld.so.conf.d/oracle-instantclient && \
#     ldconfig

#     unzip instantclient-basic-linux.x64-18.3.0.0.0dbru.zip && \
#     unzip instantclient-sdk-linux.x64-18.3.0.0.0dbru.zip && \
#     echo /opt/oracle/instantclient_18_3 > /etc/ld.so.conf.d/oracle-instantclient && \
#     ldconfig
#     # ln -s /opt/oracle/instantclient_18_3/libclntsh.so.18.1 /opt/oracle/instantclient_18_3/libclntsh.so
#     # ln -s /opt/oracle/instantclient_18_3/libocci.so.18.1 /opt/oracle/instantclient_18_3/libocci.so

# apt install -y php-dev php-pear build-essential libaio1 && \
#     curl -SL http://pecl.php.net/get/oci8 -o oci8.tgz && \
#     pecl install --force oci8.tgz && \
#     echo 'extension=oci8.so' > $PHP_INI_DIR/90-oci8.ini

cd ~
