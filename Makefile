GROUP=scce
BUILD=docker build -t $(GROUP)/
DEPLOY=./deploy.sh master

build-dywa-backup:
	$(BUILD)dywa-backup dywa-backup/src

build-dywa-postgres:
	$(BUILD)dywa-postgres dywa-postgres

build-mailcatcher:
	$(BUILD)mailcatcher mailcatcher

build-maven:
	$(BUILD)maven mailcatcher

deploy-dywa-backup-latest:
	$(DEPLOY) dywa-backup/latest

deploy-dywa-postgres-latest:
	$(DEPLOY) dywa-postgres/latest

deploy-dywa-mailcatcher-latest:
	$(DEPLOY) dywa-mailcatcher/latest

deploy-dywa-maven-latest:
	$(DEPLOY) dywa-maven/latest

build-all: build-dywa-backup build-dywa-postgres build-mailcatcher build-maven
