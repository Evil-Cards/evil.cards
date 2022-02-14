APP_NAME=evil-cards-256417
RELEASE_VERSION = 1
GIT_VERSION=$(shell (git rev-parse HEAD 2>/dev/null || echo "${BUILD_VCS_NUMBER} - ${BUILD_NUMBER}") | cut -c1-12)
PWD=$(shell pwd)
BUCKET_BASE=~/.buckets
BUCKET_PATH=$(BUCKET_BASE)/$(APP_NAME)
APP_SERVER= $(shell which dev_appserver.py)
# https://www.palettable.io/17192E-4C4C4E-92187B-E6C242-DF1B1B
clean:
	# Removes all files generated during setup, returning the repository to only checked in and gitignored files.
	if [ -e app.tar.gz ]; then rm app.tar.gz; fi;
	# delete datastore_export
	if [ -e datastore_export ]; then rm -rf datastore_export; fi;
	# delete all locally installed node_modules
	if [ -e node_modules ]; then rm -rf node_modules; fi;
	if [ -e static/assets/icons ]; then rm -rf static/assets/icons/*; fi;

dev: clean
	# Creates a development environment, with indication of next steps for local testing if not clear.
	# https://cloud.google.com/appengine/docs/standard/python/tools/local-devserver-command
	# https://stackoverflow.com/questions/47988810
	# keep? --env_var APPLICATION_ID=it-cron
	python2 $(APP_SERVER) $(PWD)/default/app.yaml -A=$(APP_NAME) --host=localhost --log_level info  --clear_datastore  --default_gcs_bucket_name $(APP_NAME).appspot.com --storage_path=$(BUCKET_PATH) --enable_console --enable_host_checking=false

datastore_clear:
	dev_appserver.py --clear_datastore=yes app.yaml

datastore_emulator_start:
	# https://cloud.google.com/datastore/docs/tools/emulator-export-import
	# https://cloud.google.com/datastore/docs/tools/datastore-emulator
	gcloud beta emulators datastore start &
datastore_export:
	gsutil -m rm -rf gs://$(APP_NAME).appspot.com/datastore_export
	gcloud datastore export gs://$(APP_NAME).appspot.com/datastore_export
datastore_operations_list:
	gcloud datastore operations list
datastore_import:
	gsutil -m cp -r gs://$(APP_NAME).appspot.com/datastore_export .
	curl -X POST localhost:8081/v1/projects/$(APP_NAME):import \
	-H 'Content-Type: application/json' \
	-d '{"input_url":"datastore_export/datastore_export.overall_export_metadata"}'

datastore_indexes_create:
	# https://cloud.google.com/sdk/gcloud/reference/datastore/create-indexes
	gcloud datastore indexes create index.yaml

datastore_indexes_create:
	# https://cloud.google.com/sdk/gcloud/reference/datastore/create-indexes
	gcloud datastore indexes create index.yaml

release:
	# This target pushes the project into production. Confirmation or warning is preferred, should be “yesable”
	# gcloud components update -q
	gcloud app deploy default/app.yaml --project $(APP_NAME) --version $(GIT_VERSION) --verbosity info
	# gcloud app deploy default/cron.yaml --project $(APP_NAME) --version $(GIT_VERSION) --verbosity info

	# remove unused indexes
	#gcloud datastore indexes cleanup index.yaml --project $(APP_NAME) --quiet --verbosity info
	# updates indexes
	#gcloud datastore indexes create index.yaml --project $(APP_NAME) --quiet --verbosity info

setcreds:
	# https://cloud.google.com/sdk/gcloud/reference/auth/application-default/login
	# Used only for application runas - for development use setproject
	gcloud auth application-default login

setproject:
	# If you have multiple auth accounts, you may also need to run gcloud auth login email@domain.com
	gcloud auth login
	gcloud config set project $(APP_NAME)
	gcloud auth list

setup:
	#First time Devs run this. 
	@echo checking for ${GCLOUD}
	@if [ ! -x "${GCLOUD}" ]; then curl https://sdk.cloud.google.com | sudo bash ; \
	gcloud components update ; \
	gcloud init ; \
	fi


build:
	docker-compose build

dev:
	docker-compose up