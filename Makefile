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
			&& (cd iac && terraform init)'

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

.PHONY: _test-targeted-infra-up
_test-targeted-infra-up:
	docker run ${ALL_THE_DOCKER_ARGS} \
		bash -c 'git config --global --add safe.directory /app \
		&& cd iac && terraform init && terraform apply -auto-approve -var-file="tfvars/dev/s.tfvars" -target="module.vpc" -target="module.bastion"'

.PHONY: _test-non-targeted-infra-up
_test-non-targeted-infra-up:
	docker run ${ALL_THE_DOCKER_ARGS} \
		bash -c 'chmod +x iac/apply-over-sshuttle.sh \
		&& iac/apply-over-sshuttle.sh'

.PHONY: test-infra-up
test-infra-up: _test-targeted-infra-up _test-non-targeted-infra-up

.PHONY: _test-targeted-infra-down
_test-targeted-infra-down:
	docker run ${ALL_THE_DOCKER_ARGS} \
		bash -c 'chmod +x iac/destroy-over-sshuttle.sh \
		&& iac/destroy-over-sshuttle.sh'

.PHONY: _test-non-targeted-infra-down
_test-non-targeted-infra-down:
	docker run ${ALL_THE_DOCKER_ARGS} \
		bash -c 'git config --global --add safe.directory /app \
		&& cd iac && terraform init && terraform destroy -auto-approve -var-file="tfvars/dev/s.tfvars"'

.PHONY: test-infra-down
test-infra-down: _test-targeted-infra-down _test-non-targeted-infra-down

.PHONY: _test-start-session
_test-start-session: _create-folders
	docker run ${ALL_THE_DOCKER_ARGS} \
		bash -c 'chmod +x iac/connect.sh \
		&& iac/connect.sh'

.PHONY: _test-all
_test-all:
	docker run ${ALL_THE_DOCKER_ARGS} \
		bash -c 'git config --global --add safe.directory /app \
		&& chmod +x ./test/test-all.sh \
		&& ./test/test-all.sh'
