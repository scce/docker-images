#!/bin/sh
case "$1" in
  "-local")
    pub get
    export local=true
    /root/.pub-cache/bin/webdev serve --hostname=0.0.0.0
    ;;
  "-production")
    cp -r /webapp/* /webbuild/
    cd /webbuild
    pub get
    /root/.pub-cache/bin/webdev build
    cp -r ./build/* /usr/share/nginx/html/
    ;;
  *)
    echo "Please specify the mode: [\"-local\", \"-production\"]"
    exit 0
    ;;
esac