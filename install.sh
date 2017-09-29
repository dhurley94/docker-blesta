#!/usr/bin/env bash

if [ "$(ls -A $APACHE_DOCUMENT_ROOT)" ]; then
    true
else
    cp -R blesta/* $APACHE_DOCUMENT_ROOT
    chown -R "${APACHE_RUN_USER}:${APACHE_RUN_GROUP}" "${APACHE_DOCUMENT_ROOT}";
fi
