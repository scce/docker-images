FROM ruby:2.4-alpine3.6

LABEL maintainer="Tim Tegeler <tim.tegeler@tu-dortmund.de>"

RUN set -xe \
    && apk add --no-cache \
        libstdc++ \
        sqlite-libs \
    && apk add --no-cache --virtual .build-deps \
        build-base \
        sqlite-dev \
    && gem install mailcatcher -v 0.7.1 --no-ri --no-rdoc \
    && apk del .build-deps

# smtp port
EXPOSE 1025

# webserver port
EXPOSE 1080

ENV HTTP_PATH /

CMD mailcatcher --foreground --ip 0.0.0.0 --http-path $HTTP_PATH
