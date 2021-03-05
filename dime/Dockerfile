FROM debian:9.13
ENV DIME_FILE dime-latest-linux.zip
RUN apt-get update -qq && \
      apt-get upgrade -qq && \
      apt-get install -qq unzip
ADD https://ls5download.cs.tu-dortmund.de/dime/daily/$DIME_FILE .
RUN unzip -qq $DIME_FILE && \
      mv DIME* DIME

FROM debian:9.13
RUN apt-get update -qq && \
      apt-get upgrade -qq && \
      apt-get install -qq openjdk-8-jdk
COPY --from=0 DIME DIME
