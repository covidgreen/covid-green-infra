#!/bin/bash
set -eou pipefail

cluster_identifier=${1:-xyz-dev-rds}

cluster_attributes='DatabaseName Engine EngineVersion PreferredBackupWindow PreferredMaintenanceWindow'
db_instance_attributes='DBInstanceClass PreferredBackupWindow AvailabilityZone PreferredMaintenanceWindow MonitoringInterval Endpoint.Address Endpoint.Port'
green_text='\e[32m'
reset_text='\e[0m'

cluster_data=$(aws rds describe-db-clusters --db-cluster-identifier ${cluster_identifier} --output json | jq .DBClusters[0])
echo -e "${green_text}${cluster_identifier}${reset_text}"
for key in ${cluster_attributes}; do
	echo ${key}: $(jq -r .${key} <<< ${cluster_data})
done

db_instances_data=$(aws rds describe-db-instances --filters Name=db-cluster-id,Values=${cluster_identifier} --output json)
for db_instance_identifier in $(jq -r .DBInstances[].DBInstanceIdentifier <<< ${db_instances_data}); do
	echo -e "\n\t${green_text}${db_instance_identifier}${reset_text}"
	db_instance_data=$(jq '.DBInstances[] | select(.DBInstanceIdentifier == "'${db_instance_identifier}'")' <<< $db_instances_data)
	for key in ${db_instance_attributes}; do
		echo -e "\t${key}: $(jq -r .${key} <<< ${db_instance_data})"
	done
done
