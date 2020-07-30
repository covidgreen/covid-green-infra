## DB cluster info
See the [script](../scripts/report-rds-cluster-key-attributes.sh)
- Each cluster node has a different maintenance window
	- Since we use a module to create/manage the RDS cluster, we cannot set this


## Connecting to the DB
Connection to the bastion as described [here](./bastion.md)

### Connection values
Writer host is in the prefix-db_host parameter
```
./scripts/aws-parameters.sh values dev-xyz-db_host
```

Database name is in the prefix-db_database parameter
```
./scripts/aws-parameters.sh values dev-xyz-db_database
```

Credentials are in the prefix-rds secret
```
./scripts/aws-secrets.sh values dev-xyz-rds
```


### Connect
Connect with
```
psql -h xyz-dev-rds.cluster-cbbm7etlo64v.eu-west-1.rds.amazonaws.com -U rds_admin_user -d ni
```


## PENDING - Need to work this out
## Create reader and crud users as needed by QA
Switch to postgres db
```
\c postgres
```

Create users granting access to the DB
```
CREATE USER reader WITH ENCRYPTED PASSWORD 'yourpass';
GRANT CONNECT ON DATABASE ni TO reader;

CREATE USER crud WITH ENCRYPTED PASSWORD 'yourpass';
GRANT CONNECT ON DATABASE ni TO crud;
```

Allow user privs on the DB
```
\c ni
GRANT USAGE ON SCHEMA public TO reader;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO reader;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO reader;


GRANT USAGE ON SCHEMA public TO crud;
GRANT ?? in SCHEMA public TO crud;
```
