#!/usr/bin/env bash

# enable common error handling options
set -o pipefail

# 1. Bring up the infra
# 2. wait 60 sec
# 3. Run the test to connect to the EKS cluster
# 4. Tear down
FAILURE=0
make test-infra-up || FAILURE=1
[[ $FAILURE -eq 0 ]] && echo "waiting for a few seconds for the app to come up" && sleep 60
[[ $FAILURE -eq 0 ]] && make _test-start-session || FAILURE=1
make test-infra-down || FAILURE=1
exit $FAILURE
