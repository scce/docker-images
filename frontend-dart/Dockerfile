FROM google/dart:2.1

RUN pub global activate webdev

ENV BOOTSTRAP_LOCATION=/usr/local/bin/bootstrap
ADD bootstrap.sh $BOOTSTRAP_LOCATION
RUN chmod +x $BOOTSTRAP_LOCATION

RUN mkdir /webbuild
RUN mkdir -p /usr/share/nginx/html/

WORKDIR /webapp

ENTRYPOINT ["/usr/local/bin/bootstrap"]
