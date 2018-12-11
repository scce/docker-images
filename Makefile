GROUP=scce
BUILD=docker build -t $(GROUP)/

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

build-all: build-alex-client build-alex-server build-dywa-nginx build-frontend-dart build-dywa-postgres build-frontend-nginx build-mailcatcher build-maven
