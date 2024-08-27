# This Makefile requires GNU Make.
MAKEFLAGS += --silent

# Settings
C_BLU='\033[0;34m'
C_GRN='\033[0;32m'
C_RED='\033[0;31m'
C_YEL='\033[0;33m'
C_END='\033[0m'


APP_ENV=dev
CURRENT_DIR=$(patsubst %/,%,$(dir $(realpath $(firstword $(MAKEFILE_LIST)))))
DIR_BASENAME=$(shell basename $(CURRENT_DIR))
ROOT_DIR=$(CURRENT_DIR)
CURRENT_DATE := $(shell date +%Y-%m-%d)

include docker/infrastructure/dev/.env

include docker/infrastructure/dev/Makefile

help: ## shows this Makefile help message
	echo 'usage: make [target]'
	echo
	echo 'targets:'
	egrep '^(.+)\:\ ##\ (.+)' ${MAKEFILE_LIST} | column -t -c 2 -s ':#'

# -------------------------------------------------------------------------------------------------
#  System Commands
# -------------------------------------------------------------------------------------------------
.PHONY: hostname fix-permission host-check show-ids php-verify wait-for-db

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

php-verify: ## Verify PHP Installation Package
	cd docker/infrastructure/dev && docker exec -it dev-backend bash /usr/local/bin/verify-php.sh

dev-db-check: ## Checks the database availability
	@docker exec -it dev-backend php artisan db:status
