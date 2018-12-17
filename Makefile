GROUP=scce
BUILD=docker build -t $(GROUP)/
DEPLOY=./deploy.sh master

build-alex-client:
	$(BUILD)alex-client alex-client

build-alex-server:
	$(BUILD)alex-server alex-server

build-dywa-nginx:
	$(BUILD)dywa-nginx dywa-nginx

build-dywa-postgres:
	$(BUILD)dywa-postgres dywa-postgres

build-frontend-dart:
	$(BUILD)frontend-dart frontend-dart

build-frontend-nginx:
	$(BUILD)frontend-nginx frontend-nginx

build-mailcatcher:
	$(BUILD)mailcatcher mailcatcher

build-maven:
	$(BUILD)maven mailcatcher

deploy-frontend-dart:
	$(DEPLOY) frontend-dart

test-frontend-nginx-config: build-frontend-nginx
	docker run --rm --name frontend-nginx scce/frontend-nginx /etc/init.d/nginx configtest

build-all: build-alex-client build-alex-server build-dywa-nginx build-frontend-dart build-dywa-postgres build-frontend-nginx build-mailcatcher build-maven
