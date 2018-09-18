FROM python:3.7-slim
RUN apt-get update && apt-get install -y --no-install-recommends \
    httpie
WORKDIR /usr/src/app

CMD ["http", "GET", "nginx"]
