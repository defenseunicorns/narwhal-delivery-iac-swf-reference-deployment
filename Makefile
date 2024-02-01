include .env

.DEFAULT_GOAL := help

# Optionally add the "-it" flag for docker run commands if the env var "CI" is not set (meaning we are on a local machine and not in github actions)
# TTY_ARG :=
# ifndef CI
# 	TTY_ARG := -it
# endif

BUILD_HARNESS_RUN := TF_VARS=$$(env | grep '^TF_VAR_' | awk -F= '{printf "-e %s ", $$1}'); \
	docker run --rm \
	--platform=linux/amd64 \
	--cap-add=NET_ADMIN \
	--cap-add=NET_RAW \
	-v "${PWD}:/app" \
	-v "${PWD}/.cache/pre-commit:/root/.cache/pre-commit" \
	-v "${PWD}/.cache/tmp:/tmp" \
	-v "${PWD}/.cache/go:/root/go" \
	-v "${PWD}/.cache/go-build:/root/.cache/go-build" \
	-v "${PWD}/.cache/.terraform.d/plugin-cache:/root/.terraform.d/plugin-cache" \
	-v "${PWD}/.cache/.zarf-cache:/root/.zarf-cache" \
	-v "${HOME}/.uds-cache:/root/.uds-cache" \
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
	$${TF_VARS} \
	${BUILD_HARNESS_REPO}:${BUILD_HARNESS_VERSION}

REGION := $(shell $(BUILD_HARNESS_RUN) bash -c 'cd iac && terraform output -raw region')
BASTION_ID := $(shell $(BUILD_HARNESS_RUN) bash -c 'cd iac && terraform output -raw bastion_instance_id')

SSM_SESSION_ARGS := \
	aws ssm start-session \
		--region $(REGION) \
		--target $(BASTION_ID) \
		--document-name AWS-StartInteractiveCommand

ZARF := zarf -l debug --no-progress --no-log-file

# The repo clone url
REPO := $(shell git remote get-url origin)
# The current branch name
BRANCH := $(shell git symbolic-ref --short HEAD)
# The "primary" directory
PRIMARY_DIR := $(shell basename $$(pwd))

.PHONY: arbitrary-container-command
arbitrary-container-command: ## Run an arbitrary command in a container. Example: make arbitrary-container-command COMMAND="ls -lahrt"
	${BUILD_HARNESS_RUN} \
		bash -c '$(COMMAND)'

.PHONY: _check-env-vars
_check-env-vars:
	echo $(PRIMARY_DIR)
	echo $(SSM_SESSION_ARGS)
	echo $(REGION)

# Silent mode by default. Run `make VERBOSE=1` to turn off silent mode.
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
_create-folders:
	mkdir -p .cache/docker
	mkdir -p .cache/pre-commit
	mkdir -p .cache/tmp
	mkdir -p .cache/.zarf-cache

.PHONY: docker-save-build-harness
docker-save-build-harness: _create-folders ## Pulls the build harness docker image and saves it to a tarball
	docker pull ${BUILD_HARNESS_REPO}:${BUILD_HARNESS_VERSION}
	docker save -o .cache/docker/build-harness.tar ${BUILD_HARNESS_REPO}:${BUILD_HARNESS_VERSION}

.PHONY: docker-load-build-harness
docker-load-build-harness: ## Loads the saved build harness docker image
	docker load -i .cache/docker/build-harness.tar

.PHONY: _runhooks
_runhooks: _create-folders
	${BUILD_HARNESS_RUN} \
	bash -c 'git config --global --add safe.directory /app \
		&& pre-commit run -a --show-diff-on-failure $(HOOK)'

.PHONY: pre-commit-all
pre-commit-all: ## Run all pre-commit hooks. Returns nonzero exit code if any hooks fail. Uses Docker for maximum compatibility
	$(MAKE) _runhooks HOOK="" SKIP=""

.PHONY: pre-commit-renovate
pre-commit-renovate: ## Run the renovate pre-commit hooks. Returns nonzero exit code if any hooks fail. Uses Docker for maximum compatibility
	$(MAKE) _runhooks HOOK="renovate-config-validator" SKIP=""

.PHONY: pre-commit-common
pre-commit-common: ## Run the common pre-commit hooks. Returns nonzero exit code if any hooks fail. Uses Docker for maximum compatibility
	$(MAKE) _runhooks HOOK="" SKIP="go-fmt,golangci-lint,terraform_fmt,terraform_docs,terraform_checkov,terraform_tflint,renovate-config-validator"

.PHONY: fix-cache-permissions
fix-cache-permissions: ## Fixes the permissions on the pre-commit cache
	docker run $(TTY_ARG) --rm -v "${PWD}:/app" --workdir "/app" -e "PRE_COMMIT_HOME=/app/.cache/pre-commit" ${BUILD_HARNESS_REPO}:${BUILD_HARNESS_VERSION} chmod -R a+rx .cache

.PHONY: autoformat
autoformat: ## Update files with automatic formatting tools. Uses Docker for maximum compatibility.
	$(MAKE) _runhooks HOOK="" SKIP="check-added-large-files,check-merge-conflict,detect-aws-credentials,detect-private-key,check-yaml,golangci-lint,terraform_checkov,terraform_tflint,renovate-config-validator"

.PHONY: _test-targeted-infra-up
_test-targeted-infra-up:
	docker run ${ALL_THE_DOCKER_ARGS} \
		bash -c 'git config --global --add safe.directory /app \
		&& cd iac && terraform init && terraform apply -auto-approve -var-file="tfvars/dev/s.tfvars" -target="module.vpc" -target="module.bastion"'

.PHONY: _test-non-targeted-infra-up
_test-non-targeted-infra-up:
	docker run ${ALL_THE_DOCKER_ARGS} \
		bash -c 'chmod +x ${SCRIPT_DIR}/apply-over-sshuttle.sh \
		&& ${SCRIPT_DIR}/apply-over-sshuttle.sh'

.PHONY: test-infra-up
test-infra-up: _test-targeted-infra-up _test-non-targeted-infra-up

.PHONY: _test-targeted-infra-down
_test-targeted-infra-down:
	docker run ${ALL_THE_DOCKER_ARGS} \
		bash -c 'chmod +x ${SCRIPT_DIR}/destroy-over-sshuttle.sh \
		&& ${SCRIPT_DIR}/destroy-over-sshuttle.sh'

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
		bash -c 'chmod +x ${SCRIPT_DIR}/connect.sh \
		&& ${SCRIPT_DIR}/connect.sh'

.PHONY: _test-all
_test-all:
	docker run ${ALL_THE_DOCKER_ARGS} \
		bash -c 'git config --global --add safe.directory /app \
		&& chmod +x ./test/test-all.sh \
		&& ./test/test-all.sh'
