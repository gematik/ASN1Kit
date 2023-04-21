#
# Makefile
#

CIBUILD			?= false
MACOSX_DEPLOYMENT_TARGET ?= 'x86_64-apple-macosx10.12'
BUILD_TYPE	?= Debug
PROJECT_DIR	:= $(PWD)

ifeq ($(CIBUILD), true)
  BUILD_TYPE = Release
endif

.PHONY: setup test build lint cibuild cli readme

setup:
	$(PROJECT_DIR)/scripts/setup ${BUILD_TYPE}

test:
	$(PROJECT_DIR)/scripts/test

build:
	$(PROJECT_DIR)/scripts/build ${BUILD_TYPE} ${MACOSX_DEPLOYMENT_TARGET}

format:
	$(PROJECT_DIR)/scripts/format

lint:
	$(PROJECT_DIR)/scripts/lint

cibuild:
	$(PROJECT_DIR)/scripts/cibuild ${BUILD_TYPE}

cli:
	bundle exec fastlane build_cli configuration:${BUILD_TYPE}

readme:
	$(PROJECT_DIR)/scripts/readme
