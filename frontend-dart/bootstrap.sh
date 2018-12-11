#!/bin/sh
case "$1" in
  "-local")
    pub get
    pub serve --hostname=0.0.0.0 --define=local=true
    ;;
  "-production")
    cp -r /webapp/* /webbuild/
    cd /webbuild
    pub get
    pub build --define=local=false
    cp -r ./build/web/* /usr/share/nginx/html/
    ;;
  *)
    echo "Please specify the mode: [\"-local\", \"-production\"]"
    exit 0
    ;;
esac