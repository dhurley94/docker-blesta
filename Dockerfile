FROM php:5.6-apache

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_DOCUMENT_ROOT /var/www/html

RUN apt-get -qq update \
    && apt-get -y -qq install wget \
    unzip \
    supervisor \
    cron \
    libpng-dev \
    libgmp-dev \
    libc-client-dev \
    libkrb5-dev \
    libmcrypt-dev \
    libreadline-dev \
    && rm -rf /var/lib/apt/lists/*

RUN wget -q -P /tmp http://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.zip \
    && unzip /tmp/ioncube_loaders_lin_x86-64.zip -d /usr/local/lib/php/extensions/ \
    && echo "zend_extension = /usr/local/lib/php/extensions/ioncube/ioncube_loader_lin_5.6.so" >  /usr/local/etc/php/conf.d/ioncube.ini \
    && rm /tmp/ioncube_loaders_lin_x86-64.zip

RUN a2enmod rewrite
RUN ln -sf /proc/self/fd/1 /var/log/apache2/access.log \
    && ln -sf /proc/self/fd/1 /var/log/apache2/error.log

RUN ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install pdo pdo_mysql gd gmp imap mcrypt \
    && pecl install mailparse-2.1.6 \
    && docker-php-ext-enable mailparse

COPY config/php.ini /usr/local/etc/php/

RUN rm -f /etc/supervisor/supervisord.conf
COPY config/supervisord.conf /etc/supervisor/supervisord.conf
COPY config/supervisorctl.conf /etc/supervisor/conf.d/

COPY config/apache2.conf /etc/supervisor/conf.d/

# These three lines may not be needed
COPY config/cron.conf /etc/supervisor/conf.d/
COPY config/blesta-cron /etc/cron.d/
RUN chmod 0644 /etc/cron.d/blesta-cron

# ADJUSTED - cronjob
RUN echo '*/5 * * * * www-data /usr/local/bin/php -q /var/www/html/index.php cron > /dev/null 2>&1' >> /etc/crontab

RUN chown -R "${APACHE_RUN_USER}:${APACHE_RUN_GROUP}" "${APACHE_DOCUMENT_ROOT}";
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

WORKDIR /var/www
RUN curl https://account.blesta.com/client/plugin/download_manager/client_main/download/116/blesta-4.3.2.zip > blesta.zip \
    && unzip blesta.zip \
    && mv /var/www/blesta/* /var/www/html \
    && mv /var/www/blesta/.htaccess /var/www/html \
    && mkdir /var/www/logs_blesta \
    && mkdir /var/www/uploads_blesta \
    && chown -R www-data:www-data /var/www 

RUN curl https://www.coinpayments.net/downloads/blesta_coinpayments.zip > /var/www/coinpayments.zip \
    && unzip coinpayments.zip \
    && mv /var/www/coin_payments /var/www/html/components/gateways/nonmerchant/

VOLUME /var/www/html
WORKDIR /var/www/html

EXPOSE 80
EXPOSE 443
EXPOSE 3306

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
