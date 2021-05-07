# DB cluster info
See the [script](../scripts/report-rds-cluster-key-attributes.sh)
- Each cluster node has a different maintenance window
	- Since we use a module to create/manage the RDS cluster, we cannot set this



# Connecting to the DB
Connection to the bastion as described [here](./bastion.md)

## Connection values
Writer host is in the prefix-db_host parameter
```
./scripts/aws-parameters.sh values dev-xyz-db_host
```

Database name is in the prefix-db_database parameter
```
./scripts/aws-parameters.sh values dev-xyz-db_database
```

Credentials are in the prefix-rds secrets - Will be 3 of them - have used
```
./scripts/aws-secrets.sh values dev-xyz-rds-read-only
```

## Connecting
Connect with
```
psql -h xyz-dev-rds.cluster-something.eu-west-1.rds.amazonaws.com -U read_only_user -d xyz
```



# Extensions configuration
Need to create the pgcrypto extension as the master user, seems you cannot/should not grant access to creating this to mormal users, see [here](https://dba.stackexchange.com/questions/175319/postgresql-enabling-extensions-without-super-user)

## Connect with rds_admin_user
```
psql -h xyz-dev-rds.cluster-something.eu-west-1.rds.amazonaws.com -U rds_admin_user -d xyz
```

## Apply
```sql
CREATE EXTENSION IF NOT EXISTS pgcrypto;
```



# Create roles/users
## Create roles/users granting access to the DB
* Read Write Create
* Read Write
* Read Only

We do this using the **rds_admin_user**

## Connect with
```
psql -h xyz-dev-rds.cluster-something.eu-west-1.rds.amazonaws.com -U rds_admin_user -d xyz
```

## Apply
```sql
# read_write_create role/user
CREATE ROLE read_write_create;

# Note we add a GRANT here
GRANT ALL PRIVILEGES ON DATABASE REPLACE-ME-DATABASE-NAME TO read_write_create;

CREATE USER read_write_create_user WITH PASSWORD 'REPLACE-ME';

GRANT read_write_create TO read_write_create_user;


# read_write role/user
CREATE ROLE read_write;

GRANT CONNECT ON DATABASE REPLACE-ME-DATABASE-NAME TO read_write;

CREATE USER read_write_user WITH PASSWORD 'REPLACE-ME-2';

GRANT read_write TO read_write_user;


# read_only role/user
CREATE ROLE read_only;

GRANT CONNECT ON DATABASE REPLACE-ME-DATABASE-NAME TO read_only;

CREATE USER read_only_user WITH PASSWORD 'REPLACE-ME';

GRANT read_only TO read_only_user;
```

## Grant privs to the read_write and read_only roles
We do this using the **read_write_create_user** which will be used for migrations and will therefore own the DB objects

### Connect
```
psql -h xyz-dev-rds.cluster-something.eu-west-1.rds.amazonaws.com -U read_write_create_user -d xyz
```

### Apply
```sql
# read_write
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON ALL TABLES IN SCHEMA public TO read_write;

GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO read_write;

ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON TABLES TO read_write;

ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE, SELECT ON SEQUENCES TO read_write;


# read_only role/user
GRANT SELECT ON ALL TABLES IN SCHEMA public TO read_only;

GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO read_only;

ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO read_only;

ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE, SELECT ON SEQUENCES TO read_only;
```

## Cleanup history
After exiting the psql session, you can clean your history so the passwords are not on the bastion disk with
```
rm ${HOME}/.psql_history
```

## Existing table modifications if required
If tables were previously created by rds_admin_user, owner has to be changed:

All tenants:
```sql
ALTER TABLE download_batches
OWNER TO read_write_create_user;

ALTER TABLE check_ins
OWNER TO read_write_create_user;

ALTER TABLE exposure_export_files
OWNER TO read_write_create_user;

ALTER TABLE exposures
OWNER TO read_write_create_user;

ALTER TABLE metrics
OWNER TO read_write_create_user;

ALTER TABLE metrics_payloads
OWNER TO read_write_create_user;

ALTER TABLE metrics_requests
OWNER TO read_write_create_user;

ALTER TABLE migrations
OWNER TO read_write_create_user;

ALTER TABLE registrations
OWNER TO read_write_create_user;

ALTER TABLE settings
OWNER TO read_write_create_user;

ALTER TABLE tokens
OWNER TO read_write_create_user;

ALTER TABLE upload_batches
OWNER TO read_write_create_user;

ALTER TABLE upload_tokens
OWNER TO read_write_create_user;

ALTER TABLE verifications
OWNER TO read_write_create_user;
```

Gibraltar specific:

```sql
ALTER TABLE gibraltar_tracker_migrations
OWNER TO read_write_create_user;

ALTER TABLE callbacks
OWNER TO read_write_create_user;
```
