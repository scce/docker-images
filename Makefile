GROUP=scce
BUILD=docker build -t $(GROUP)/
DEPLOY=./deploy.sh master

build-dywa-postgres:
	$(BUILD)dywa-postgres dywa-postgres


build-mailcatcher:
	$(BUILD)mailcatcher mailcatcher


build-maven:
	$(BUILD)maven mailcatcher


build-all: build-dywa-postgres build-mailcatcher build-maven
