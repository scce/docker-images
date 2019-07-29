GROUP=scce
BUILD=docker build -t $(GROUP)/
DEPLOY=./deploy.sh master


# dywa-nginx

build-dywa-nginx:
	$(BUILD)dywa-nginx dywa-nginx

deploy-dywa-nginx-unstable:
	$(DEPLOY) dywa-nginx/unstable


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


build-all: build-dywa-nginx build-dywa-postgres build-frontend-dart build-frontend-nginx build-mailcatcher build-maven
