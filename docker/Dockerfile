FROM alpine:3.13
LABEL maintainer="sudo@dov.moe"

# Install required packages
RUN apk --no-cache add bash php7 php7-fpm php7-opcache php7-mysqli php7-json php7-openssl php7-curl \
    php7-zlib php7-xml php7-phar php7-intl php7-dom php7-xmlreader php7-ctype php7-session \
    php7-zip php7-fileinfo php7-bcmath php7-tokenizer php7-xmlwriter php7-pcntl php7-simplexml \
    php7-mbstring php7-gd php7-redis php7-pdo php7-pdo_mysql nginx supervisor curl

# Add user and group
RUN adduser -D -g '' application && mkdir -p /run/nginx

WORKDIR /dujiaoka

COPY dujiaoka/ /dujiaoka
COPY conf/default.conf /etc/nginx/conf.d/default.conf
COPY conf/fpm-pool.conf /etc/php7/php-fpm.d/www.conf
COPY conf/php.ini /etc/php7/conf.d/custom.ini
COPY conf/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY conf/start.sh /
COPY conf/start-hook.sh /dujiaoka/start-hook.sh

# Install composer
COPY --from=composer /usr/bin/composer /usr/bin/composer

RUN set -xe \
    && composer config --unset repositories \
    && composer update --lock \
    && composer install --optimize-autoloader -vvv \
    && mv /dujiaoka/storage /dujiaoka/storage_bak \
    && sed -i "s?\$proxies;?\$proxies=\'\*\*\';?" /dujiaoka/app/Http/Middleware/TrustProxies.php \
    && rm -rf /root/.composer/cache/ /tmp/*

# Set permissions
RUN chown -R application /dujiaoka \
    && chmod -R 0755 /dujiaoka/ \
    && chmod +x /start.sh /dujiaoka/start-hook.sh

ENV INSTALL=true

ENTRYPOINT [ "/start.sh" ]
