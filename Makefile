GROUP=scce
BUILD=docker build -t $(GROUP)/
DEPLOY=./deploy.sh master

# dywa-nginx

build-dywa-nginx:
	$(BUILD)dywa-nginx dywa-nginx

deploy-dywa-nginx-unstable:
	$(DEPLOY) dywa-nginx/unstable


# alex-client

build-alex-client:
	$(BUILD)alex-client alex-client


# alex-server

build-alex-server:
	$(BUILD)alex-server alex-server


# dywa-postgres

build-dywa-postgres:
	$(BUILD)dywa-postgres dywa-postgres


# frontend-dart

build-frontend-dart:
	$(BUILD)frontend-dart frontend-dart

deploy-frontend-dart-latest:
	$(DEPLOY) frontend-dart/latest


# frontend-nginx

build-frontend-nginx:
	$(BUILD)frontend-nginx frontend-nginx

test-frontend-nginx-config: build-frontend-nginx
	docker run --rm --name frontend-nginx scce/frontend-nginx /etc/init.d/nginx configtest


# mailcatcher

build-mailcatcher:
	$(BUILD)mailcatcher mailcatcher


# maven

build-maven:
	$(BUILD)maven mailcatcher


build-all: build-alex-client build-alex-server build-dywa-nginx build-frontend-dart build-dywa-postgres build-frontend-nginx build-mailcatcher build-maven
