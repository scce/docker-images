FROM maven:3.5.4

ARG USER_HOME_DIR="/root"

RUN apt-get update && apt-get install -y --no-install-recommends \
                       openssh-client \
                       rsync

RUN mkdir -p "$USER_HOME_DIR/.m2/repository"
COPY settings.xml "$USER_HOME_DIR/.m2/settings.xml"
COPY mavenrc "$USER_HOME_DIR/.mavenrc"

RUN mkdir -p "$USER_HOME_DIR/.ssh"
COPY ssh-config "$USER_HOME_DIR/.ssh/config"
