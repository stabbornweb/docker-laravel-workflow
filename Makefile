# This Makefile requires GNU Make.
MAKEFLAGS += --silent

# Settings
C_BLU='\033[0;34m'
C_GRN='\033[0;32m'
C_RED='\033[0;31m'
C_YEL='\033[0;33m'
C_END='\033[0m'

include docker/infrastructure/dev/.env

CURRENT_DIR=$(patsubst %/,%,$(dir $(realpath $(firstword $(MAKEFILE_LIST)))))
DIR_BASENAME=$(shell basename $(CURRENT_DIR))
ROOT_DIR=$(CURRENT_DIR)
CURRENT_DATE := $(shell date +%Y-%m-%d)

help: ## shows this Makefile help message
	echo 'usage: make [target]'
	echo
	echo 'targets:'
	egrep '^(.+)\:\ ##\ (.+)' ${MAKEFILE_LIST} | column -t -c 2 -s ':#'

# -------------------------------------------------------------------------------------------------
#  System
# -------------------------------------------------------------------------------------------------
.PHONY: hostname fix-permission host-check show-ids

hostname: ## shows local machine ip
	echo $(word 1,$(shell hostname -I))
	echo $(ip addr show | grep "\binet\b.*\bdocker0\b" | awk '{print $2}' | cut -d '/' -f 1)

fix-permission: ## sets project directory permission
	$(DOCKER_USER) chown -R ${USER}: $(ROOT_DIR)/

host-check: ## shows this project ports availability on local machine
	cd docker/infrastructure/dev && $(MAKE) port-check

show-ids: ## shows UID and GID current user of OS
	echo "Your [UID] is: $$(id -u)"
	echo "Your [GID] is: $$(id -g)"

# -------------------------------------------------------------------------------------------------
#  Dev Application Service
# -------------------------------------------------------------------------------------------------
.PHONY: dev-set dev-up dev-rebuild dev-down dev-start dev-stop dev-destroy

dev-set: ## Sets the project environment file to build the container NEED FIX
	cd infrastructure/nginx-php && $(MAKE) env-set

dev-up: ## Creates the project containers from docker-compose-dev.yml file
	cd docker/infrastructure/dev && docker compose --env-file .env -f docker-compose-dev.yml up -d

dev-down: ## Stop and delete all containers
	cd docker/infrastructure/dev && docker compose --env-file .env -f docker-compose-dev.yml down

dev-rebuild: ## Rebuild the project containers from docker-compose-dev.yml file
	cd docker/infrastructure/dev && docker compose --env-file .env -f docker-compose-dev.yml up -d --build

dev-build: ## Build dev environment from docker-compose-dev.yml file
	cd docker/infrastructure/dev && docker compose --env-file .env -f docker-compose-dev.yml build

dev-start: ## Starts the project container running NEED FIX
	cd infrastructure/nginx-php && $(MAKE) start

dev-stop: ## Stops the project container but data won't be destroyed NEED FIX
	cd infrastructure/nginx-php && $(MAKE) stop

dev-destroy: ## Removes the project from Docker network destroying its data and Docker image NEED FIX
	cd infrastructure/nginx-php && $(MAKE) clear destroy

## -------------------------------------------------------------------------------------------------
##  Backend Service
## -------------------------------------------------------------------------------------------------
.PHONY: backend-ssh backend-update

backend-ssh: ## enters the backend container shell
	cd docker/infrastructure/dev && docker exec -it dev-backend bash

backend-update: ## updates the backend set version into container NEED FIX
	cd infrastructure/nginx-php && $(MAKE) app-update

## -------------------------------------------------------------------------------------------------
##  Database Service
## -------------------------------------------------------------------------------------------------
.PHONY: dev-db-shell dev-db-install dev-db-replace dev-db-backup

dev-db-shell: ## enter into dev-db container shell
	docker exec -it $(DOCKER_CONTAINER_NAME_PREFIX)-db sh

dev-db-install: ## installs into container database the init sql file from resources/database
	sudo docker exec -i $(DOCKER_CONTAINER_NAME_PREFIX)-db sh -c 'exec mysql $(DOCKER_DB_DATABASE) -uroot -p"$(DOCKER_DB_PASSWORD)"' < docker/infrastructure/dev/mysql/dev-mysql-init.sql
	echo ${C_YEL}"DATABASE"${C_END}" has been installed."

dev-db-replace: ## replaces container database with the latest sql backup file from resources/database
	sudo docker exec -i $(DOCKER_CONTAINER_NAME_PREFIX)-db sh -c 'exec mysql $(DOCKER_DB_DATABASE) -uroot -p"$(DOCKER_DB_PASSWORD)"' < docker/infrastructure/dev/mysql/dev-mysql-backup-$(CURRENT_DATE).sql
	echo ${C_YEL}"DATABASE"${C_END}" has been replaced."

dev-db-backup: ## creates / replace a sql backup file from container database in resources/database
	sudo docker exec $(DOCKER_CONTAINER_NAME_PREFIX)-db sh -c 'exec mysqldump $(DOCKER_DB_DATABASE) -uroot -p"$(DOCKER_DB_PASSWORD)"' > docker/infrastructure/dev/mysql/dev-mysql-backup-$(CURRENT_DATE).sql
	echo ${C_YEL}"DATABASE"${C_END}" backup has been created."

## -------------------------------------------------------------------------------------------------
##  Repository Helper
## -------------------------------------------------------------------------------------------------
repo-flush: ## clears local git repository cache specially to update .gitignore
	git rm -rf --cached .
	git add .
	git commit -m "fix: cache cleared for untracked files"

repo-commit: ## echoes common git commands
	echo "git add . && git commit -m \"maint: ... \" && git push -u origin main"
