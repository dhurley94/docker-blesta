FROM debian:jessie

ENV BLESTA_VER 4.1.1

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_DOCUMENT_ROOT /var/www/html

RUN apt-get -qq update \
    && apt-get -y -qq install wget \
    unzip \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp

RUN wget -q -P /tmp https://account.blesta.com/client/plugin/download_manager/client_main/download/97/blesta-${BLESTA_VER}.zip \
    && unzip /tmp/blesta-${BLESTA_VER}.zip \
    && mv blesta/* ${APACHE_DOCUMENT_ROOT}
    
RUN chown -R "${APACHE_RUN_USER}:${APACHE_RUN_GROUP}" "${APACHE_DOCUMENT_ROOT}";
