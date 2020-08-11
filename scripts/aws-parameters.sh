#!/bin/bash
#	./aws-parameters.sh list
#	./aws-parameters.sh list dev-xyz-
#
#	./aws-parameters.sh values
#	./aws-parameters.sh values dev-xyz-
#
set -eou pipefail

green_text='\e[32m'
reset_text='\e[0m'


list() {
	# NOTE: Ignoring paging here, assumes we do not have a large number of secrets in our case - KISS
	prefix=${1:-}
	aws ssm describe-parameters --output json | jq -r '.Parameters[] | select(.Name | startswith("'${prefix}'"))| .Name' | sort
}

values() {
	prefix=${1:-}
	for name in $(list "${prefix}"); do
 		value=$(aws ssm get-parameter --name ${name} --with-decryption --output json | jq -r .Parameter.Value)
		echo -e "${green_text}${name}${reset_text}\n${value}\n"
	done
}


# Main
"$@"
