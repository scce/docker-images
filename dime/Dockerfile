FROM debian:9.13

RUN apt-get update -qq && \
      apt-get upgrade -qq && \
      apt-get install -qq openjdk-8-jdk unzip

ADD https://ls5download.cs.tu-dortmund.de/dime/daily/dime2-latest-linux.zip .

RUN unzip -qq dime2-latest-linux.zip && \
      rm dime2-latest-linux.zip && \
      mv DIME* DIME