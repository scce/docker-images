#!/usr/bin/env bash

SOURCE="$1"
TARGET="$2"

git checkout ${SOURCE} && \
    git pull && \
    git push && \
    git checkout ${TARGET} && \
    git merge ${SOURCE} && \
    git pull && \
    git push && \
    git checkout master
