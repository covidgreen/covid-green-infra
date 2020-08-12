#!/bin/bash
# Assumes you have set your AWS_PROFILE or credentials - including the region
#	./aws-secrets.sh list
#	./aws-secrets.sh list dev-xyz-
#
#	./aws-secrets.sh values
#	./aws-secrets.sh values dev-xyz-
#
#	./aws-secrets.sh create dev-xyz-device-check 'SOME-VALUE'
#	./aws-secrets.sh create dev-xyz-jwt "{\"key\": \"ABC{'&m\`<N\`\"}"		# Illustrates where we have to escape the ` char
#
set -eou pipefail

green_text='\e[32m'
reset_text='\e[0m'


create() {
	# NOTE: Not catering for KMS, description, tags etc. here - KISS
	: ${1?Secret name is required}
	: ${2?Secret value is required}

	name=${1}
	value=${2}
	aws secretsmanager create-secret --name ${name} --secret-string "${value}"
}

list() {
	# NOTE: Ignoring paging here, assumes we do not have a large number of secrets in our case - KISS
	prefix=${1:-}
	aws secretsmanager list-secrets --output json | jq -r '.SecretList[] | select(.Name | startswith("'${prefix}'"))| .Name' | sort
}

values() {
	prefix=${1:-}
	for name in $(list "${prefix}"); do
		value=$(aws secretsmanager get-secret-value --secret-id ${name} --output json | jq -r .SecretString)
		echo -e "${green_text}${name}${reset_text}\n${value}\n"
	done
}


# Main
"$@"
