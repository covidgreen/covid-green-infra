#!/bin/bash
# Assumes you have already configured your AWS_PROFILE or env vars and have privs to create resources
#
# Note this is not idempotent, would make more sense to just use TF without a backend to create these resources
#
# Probably should have something for rotating the access keys periodically
#
# Usage is
#	./create-infra-ci-user.sh dev-xyz
#	./create-infra-ci-user.sh dev-abc
#	./create-infra-ci-user.sh prod-xyz
#
set -eou pipefail
: ${1?Project-env required, i.e. dev-xyz}

# Vars
user_name=${1}-infra-ci
privileged_policy_arn=${2:-arn:aws:iam::aws:policy/AdministratorAccess}		# Unless we can create a more restrictive policy


# Create IAM user
aws iam create-user --user-name ${user_name}

# Attach privileged policy
aws iam attach-user-policy --user-name ${user_name} --policy-arn ${privileged_policy_arn}

# Create access keys
aws iam create-access-key --user-name ${user_name}
