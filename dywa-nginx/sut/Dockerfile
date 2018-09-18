FROM python:3.7-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    httpie

ADD https://github.com/vi/websocat/releases/download/v1.1.0/websocat_1.1.0_amd64.deb /tmp/
RUN dpkg -i /tmp/websocat_1.1.0_amd64.deb

WORKDIR /usr/src/app
COPY test.sh .
RUN chmod +x test.sh

CMD ["./test.sh"]
