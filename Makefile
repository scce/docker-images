GROUP=scce
BUILD=docker build -t $(GROUP)/
DEPLOY=./deploy.sh master

# dywa-postgres

build-dywa-postgres:
	$(BUILD)dywa-postgres dywa-postgres


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


build-all: build-dywa-postgres build-frontend-nginx build-mailcatcher build-maven
