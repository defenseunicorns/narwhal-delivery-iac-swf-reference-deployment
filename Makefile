include .env

.DEFAULT_GOAL := help

SHELL := /bin/bash

ZARF := zarf -l debug --no-progress --no-log-file

ALL_THE_DOCKER_ARGS := -it --rm \
	--cap-add=NET_ADMIN \
	--cap-add=NET_RAW \
	-v "${PWD}:/app" \
	-v "${PWD}/.cache/pre-commit:/root/.cache/pre-commit" \
	-v "${PWD}/.cache/tmp:/tmp" \
	-v "${PWD}/.cache/go:/root/go" \
	-v "${PWD}/.cache/go-build:/root/.cache/go-build" \
	-v "${PWD}/.cache/.terraform.d/plugin-cache:/root/.terraform.d/plugin-cache" \
	-v "${PWD}/.cache/.zarf-cache:/root/.zarf-cache" \
	--workdir "/app" \
	-e TF_LOG_PATH \
	-e TF_LOG \
	-e GOPATH=/root/go \
	-e GOCACHE=/root/.cache/go-build \
	-e TF_PLUGIN_CACHE_MAY_BREAK_DEPENDENCY_LOCK_FILE=true \
	-e TF_PLUGIN_CACHE_DIR=/root/.terraform.d/plugin-cache \
	-e AWS_REGION \
	-e AWS_DEFAULT_REGION \
	-e AWS_ACCESS_KEY_ID \
	-e AWS_SECRET_ACCESS_KEY \
	-e AWS_SESSION_TOKEN \
	-e AWS_SECURITY_TOKEN \
	-e AWS_SESSION_EXPIRATION \
	${BUILD_HARNESS_REPO}:${BUILD_HARNESS_VERSION}

# The current branch name
BRANCH := $(shell git symbolic-ref --short HEAD)
# The "primary" directory
PRIMARY_DIR := $(shell pwd)

# Silent mode by default. Run `make <the-target> VERBOSE=1` to turn off silent mode.
ifndef VERBOSE
.SILENT:
endif

# Idiomatic way to force a target to always run, by having it depend on this dummy target
FORCE:

.PHONY: help
help: ## Show available user-facing targets
	grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| sed -n 's/^\(.*\): \(.*\)##\(.*\)/\1:\3/p' \
	| column -t -s ":"

.PHONY: help-dev
help-dev: ## Show available dev-facing targets
	grep -E '^_[a-zA-Z0-9_-]+:.*?#_# .*$$' $(MAKEFILE_LIST) \
	| sed -n 's/^\(.*\): \(.*\)#_#\(.*\)/\1:\3/p' \
	| column -t -s ":"

.PHONY: help-internal
help-internal: ## Show available internal targets
	grep -E '^\+[a-zA-Z0-9_-]+:.*?#\+# .*$$' $(MAKEFILE_LIST) \
	| sed -n 's/^\(.*\): \(.*\)#\+#\(.*\)/\1:\3/p' \
	| column -t -s ":"

.PHONY: _test-all
_test-all:
	$(MAKE) _create-folders
	echo "Running automated tests. This will take several minutes. At times it does not log anything to the console. If you interrupt the test run you will need to log into AWS console and manually delete any orphaned infrastructure."
	TF_VARS=$$(env | grep '^TF_VAR_' | awk -F= '{printf "-e %s ", $$1}');
	bash -c 'git config --global --add safe.directory /app && cd terraform && terraform init -upgrade=true && cd ../test/e2e && go test -count 1 -v $(EXTRA_TEST_ARGS) .'

.PHONY: _create-folders
_create-folders: ## Create the .cache folder structure
	mkdir -p .cache/docker
	mkdir -p .cache/pre-commit
	mkdir -p .cache/go
	mkdir -p .cache/go-build
	mkdir -p .cache/tmp
	mkdir -p .cache/.terraform.d/plugin-cache
	mkdir -p .cache/.zarf-cache

.PHONY: _docker-save-build-harness
_docker-save-build-harness: _create-folders ## Save the build-harness docker image to the .cache folder
	docker pull ${BUILD_HARNESS_REPO}:${BUILD_HARNESS_VERSION}
	docker save -o .cache/docker/build-harness.tar ${BUILD_HARNESS_REPO}:${BUILD_HARNESS_VERSION}

.PHONY: _docker-load-build-harness
_docker-load-build-harness: ## Load the build-harness docker image from the .cache folder
	docker load -i .cache/docker/build-harness.tar

.PHONY: _update-cache
_update-cache: _create-folders _docker-save-build-harness ## Update the cache
	docker run ${ALL_THE_DOCKER_ARGS} \
		bash -c 'git config --global --add safe.directory /app \
			&& pre-commit install --install-hooks \
			&& (cd test/iac && terraform init)'

.PHONY: _runhooks
_runhooks: _create-folders ## Helper "function" for running pre-commits
	docker run ${ALL_THE_DOCKER_ARGS} \
		bash -c 'git config --global --add safe.directory /app \
		&& pre-commit run -a --show-diff-on-failure $(HOOK)'

.PHONY: pre-commit-all
pre-commit-all: ## [Docker] Run all pre-commit hooks
	$(MAKE) _runhooks HOOK="" SKIP=""

.PHONY: pre-commit-terraform
pre-commit-terraform: ## [Docker] Run terraform pre-commit hooks
	$(MAKE) _runhooks HOOK="" SKIP="check-added-large-files,check-merge-conflict,detect-aws-credentials,detect-private-key,end-of-file-fixer,fix-byte-order-marker,trailing-whitespace,check-yaml,fix-smartquotes,renovate-config-validator"
.PHONY: pre-commit-renovate
pre-commit-renovate: ## [Docker] Run renovate pre-commit hooks
	$(MAKE) _runhooks HOOK="renovate-config-validator" SKIP=""

.PHONY: pre-commit-common
pre-commit-common: ## [Docker] Run common pre-commit hooks
	$(MAKE) _runhooks HOOK="" SKIP="terraform_fmt,terraform_docs,terraform_checkov,terraform_tflint,renovate-config-validator"

.PHONY: _fix-cache-permissions
_fix-cache-permissions: ## [Docker] Fix permissions on the .cache folder
	docker run $(TTY_ARG) --rm -v "${PWD}:/app" --workdir "/app" -e "PRE_COMMIT_HOME=/app/.cache/pre-commit" ${BUILD_HARNESS_REPO}:${BUILD_HARNESS_VERSION} chmod -R a+rx .cache


.PHONY: plan-dev-environment
plan-dev-environment: ## Build the dev environment docker image
	cd terraform && terraform init && terraform plan -var-file="tfvars/base/s.tfvars" -var-file="tfvars/dev/s.tfvars"

.PHONY: build-dev-environment
build-dev-environment: ## Build the dev environment docker image
	cd terraform && terraform init && terraform apply -var-file="tfvars/base/s.tfvars" -var-file="tfvars/dev/s.tfvars"

.PHONY: destroy-dev-environment
destroy-dev-environment: ## Build the dev environment docker image
	cd terraform && terraform destroy -var-file="tfvars/base/s.tfvars" -var-file="tfvars/dev/s.tfvars"

.PHONY: test-complete-secure
test-complete-secure: ## Run one test (TestCompleteSecure). Requires access to an AWS account. Costs real money.
	$(eval export TF_VAR_region := $(or $(REGION),$(TF_VAR_region),us-gov-west-1))
	$(MAKE) _test-all EXTRA_TEST_ARGS="-timeout 3h -run TestCompleteSecure"

.PHONY: test-complete-plan-only
test-complete-plan-only: ## Run one test (TestCompletePlanOnly). Requires access to an AWS account. It will not cost money or create any resources since it is just running `terraform plan`.
	$(eval export TF_VAR_region := $(or $(REGION),$(TF_VAR_region),us-gov-west-1))
	$(MAKE) _test-all EXTRA_TEST_ARGS="-timeout 3h -run TestCompletePlanOnly"
