FROM php:5.6-apache

ENV BLESTA_VERSION 4.1.0

RUN apt-get update \
    && apt-get -y install wget unzip \
    && rm -rf /var/lib/apt/lists/*
	
RUN wget -q -P /tmp http://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.zip \
&& wget -q -P /tmp https://account.blesta.com/client/plugin/download_manager/client_main/download/97/blesta-${BLESTA_VERSION}.zip
	
RUN unzip /tmp/ioncube_loaders_lin_x86-64.zip -d /usr/local/lib/php/extensions/ && \
	echo "zend_extension = /usr/local/lib/php/extensions/ioncube/ioncube_loader_lin_5.6.so" >  /usr/local/etc/php/conf.d/ioncube.ini
	
RUN a2enmod rewrite
RUN docker-php-ext-install pdo pdo_mysql

RUN unzip -d /var/www /tmp/blesta-${BLESTA_VERSION}.zip blesta/*
ENV APACHE_DOCUMENT_ROOT /var/www/blesta

RUN rm /tmp/blesta-${BLESTA_VERSION}.zip \
    && rm /tmp/ioncube_loaders_lin_x86-64.zip

EXPOSE 80
CMD ["apache2-foreground"]
