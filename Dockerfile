FROM php:5.6-fpm

RUN apt-get update && apt-get install -y \
      bzip2 \
      libcurl4-openssl-dev \
      libfreetype6-dev \
      libicu-dev \
      libjpeg-dev \
      libmcrypt-dev \
      libpng12-dev \
      libpq-dev \
      libxml2-dev \
      mysql-client \
      unzip \
 && rm -rf /var/lib/apt/lists/*

# https://doc.owncloud.org/server/8.1/admin_manual/installation/source_installation.html#prerequisites
RUN docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
 && docker-php-ext-install gd intl mbstring mcrypt mysql opcache pdo_mysql zip json xmlrpc

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
  echo 'opcache.memory_consumption=128'; \
  echo 'opcache.interned_strings_buffer=8'; \
  echo 'opcache.max_accelerated_files=4000'; \
  echo 'opcache.revalidate_freq=60'; \
  echo 'opcache.fast_shutdown=1'; \
  echo 'opcache.enable_cli=1'; \
} > /usr/local/etc/php/conf.d/opcache-recommended.ini

# PECL extensions
RUN pecl install APCu-beta \ 
 && docker-php-ext-enable apcu

ENV KNOWN_VERSION 0.8.5
VOLUME /var/www/html

RUN curl -o known.tar.gz -SL https://github.com/idno/Known/archive/v${KNOWN_VERSION}.tar.gz \
 && tar -xzf known.tar.gz -C /usr/src/ \
 && mv /usr/src/Known-${KNOWN_VERSION} /usr/src/known \
 && rm known.tar.gz \
 && cd /usr/src/known/IdnoPlugins \
 && curl -L https://github.com/idno/Twitter/archive/master.zip -o twitter.zip \
 && unzip twitter.zip \
 && mv Twitter-master/ Twitter \
 && rm twitter.zip \
 && curl -L https://github.com/idno/Facebook/archive/master.zip -o facebook.zip \
 && unzip facebook.zip \
 && mv Facebook-master/ Facebook \
 && rm facebook.zip \
 && curl -L https://github.com/idno/Markdown/archive/master.zip -o markdown.zip \
 && unzip markdown.zip \
 && mv Markdown-master/ Markdown \
 && rm markdown.zip \
 && curl -L https://github.com/pierreozoux/KnownAppNet/archive/master.zip -o app-net.zip \
 && unzip app-net.zip \
 && mv KnownAppNet-master AppNet \
 && rm app-net.zip 

COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm"]
