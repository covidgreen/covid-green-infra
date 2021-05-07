# Checklist
Using a project with key **xyz** and a **dev** environment


## Create an AWS profile
Add a xyz-dev profile to ~/.aws/credentials


## Create the infra CI user - admin privs by default
See [script](../scripts/create-infra-ci-user.sh)

```
# Set your AWS_PROFILE
export AWS_PROFILE=xyz-dev

# Create
./scripts/create-infra-ci-user.sh dev-xyz

# Grab the sensitive infra ci user credentials and configure in the CI system - these are VERY sensitive so treat with care
```


## Create the Terraform state backend
See [script](../scripts/create-tf-state-backend.sh)

```
# Set your AWS_PROFILE
export AWS_PROFILE=xyz-dev

# Create
./scripts/create-tf-state-backend.sh eu-west-1 xyz-dev-terraform-store xyz-dev-terraform-lock
```


## Import TLS certificates
In some cases we need to use certificates that are supplied
- PENDING Import certicates script

In some cases we need to use certificates that we manage but we do NOT manage the DNS
- Will require the DNS domain owner to create CNAMEs to complete the AWS ACM certificate request


## DNS
In some cases where we manage the DNS we may need to help with additional DNS record creation i.e. Naked domain config.


## Create the AWS SecretsManager secrets
We need to create the secrets outside of Terraform, see the [secrets/parameters](./secrets-parameters.md) doc.

Like so - may have to watch for funny chars needing escaping - ignored here
```
generate-random() {
	length=${1:-32}

	LC_ALL=C tr -dc 'A-Za-z0-9()*+,-./:;<=>?[\]^_{|}~' </dev/urandom | head -c ${length} ; echo
}

generate-random-alphanumeric() {
	length=${1:-32}

	LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c ${length} ; echo
}

./scripts/aws-secrets.sh create dev-xyz-device-check '{ "keyId": "FILL-ME-IN", "teamId": "FILL-ME-IN", "key": "-----BEGIN PRIVATE KEY-----\nFILL-ME-IN\n-----END PRIVATE KEY-----", "apkPackageName": "", "apkDigestSha256": "", "apkCertificateDigestSha256": "", "safetyNetRootCa": "-----BEGIN CERTIFICATE-----\nFILL-ME-IN\n-----END CERTIFICATE-----", "timeDifferenceThresholdMins": 10 }'
./scripts/aws-secrets.sh create dev-xyz-encrypt '{ "key": "'$(generate-random 32)'" }'
./scripts/aws-secrets.sh create dev-xyz-exposures '{ "privateKey": "-----BEGIN EC PRIVATE KEY-----\nFILL-ME-IN\n-----END EC PRIVATE KEY-----", "signatureAlgorithm": "1.2.840.10045.4.3.2", "verificationKeyId": "", "verificationKeyVersion": "v1" }'
./scripts/aws-secrets.sh create dev-xyz-header-x-secret '{ "header-secret": "'$(generate-random-alphanumeric 96)'" }'
./scripts/aws-secrets.sh create dev-xyz-jwt '{ "key": "'$(generate-random 32)'" }'
./scripts/aws-secrets.sh create dev-xyz-rds '{ "username": "rds_admin_user", "password": "'$(generate-random 32)'" }'
./scripts/aws-secrets.sh create dev-xyz-rds-read-only '{ "username": "read_only_user", "password": "'$(generate-random 32)'" }'
./scripts/aws-secrets.sh create dev-xyz-rds-read-write '{ "username": "read_write_user", "password": "'$(generate-random 32)'" }'
./scripts/aws-secrets.sh create dev-xyz-rds-read-write-create '{ "username": "read_write_create_user", "password": "'$(generate-random 32)'" }'
./scripts/aws-secrets.sh create dev-xyz-verify '{ "keyId": "1", "privateKey": "-----BEGIN EC PRIVATE KEY-----\nFILL-ME-IN\n-----END EC PRIVATE KEY-----", "publicKey": "-----BEGIN PUBLIC KEY-----\nFILL-ME-IN\n-----END PUBLIC KEY-----" }'

# Do the same for optionals
```
**Note:** the rds secret is particularly important as changing it will require an RDS replacement as far as I can tell


## Create project content
There are 2 approaches to doing this

### a) Use a dedicated git repo
This is the preferred approach, in this case we treat this repo as a Terraform module

#### Git repo
Create a git repo which uses this repo's content as a a module
- Will need a module which points at this repo as the module source
- Will need a variables.tf copy
- Will need an ouputs.tf copy

#### env-vars files

| File                    | Content                                                    |
| ------------------------| -----------------------------------------------------------|
| env-vars/common.tfvars  | Contains values that are the same across all envs          |
| env-vars/dev.tfvars     | Contains values that are specific to the dev env           |

With these we need to decide on some optionals
- Enable DNS where we manage the DNS, in some cases we do not manage the DNS
- Enable TLS certificates where we manage the certificates, in some cases we need to import certificates
- Some lambdas are optional
- Some secrets/parameters are optional

#### Create the Makefile targets
Will need to create the following targets

| Target        | Description                                                                        |
| --------------| -----------------------------------------------------------------------------------|
| dev-init      | Does the Terraform module pulls and backend config                                 |
| dev-plan      | Runs a Terraform plan, creating a local TF plan file i.e. terraform-dev.tfplan     |
| dev-apply     | Does a Terraform apply using the created TF plan file                              |

### b) Add content in this repo
#### env-vars files

| File                    | Content                                                    |
| ------------------------| -----------------------------------------------------------|
| env-vars/xyz.tfvars     | Contains the xyx values that are the same across all envs  |
| env-vars/xyz-dev.tfvars | Contains the xyz values that are specific to the dev env   |

With these we need to decide on some optionals
- Enable DNS where we manage the DNS, in some cases we do not manage the DNS
- Enable TLS certificates where we manage the certificates, in some cases we need to import certificates
- Some lambdas are optional
- Some secrets/parameters are optional

#### Create the Makefile targets
Will need to create the following targets.

| Target        | Description                                                                        |
| --------------| -----------------------------------------------------------------------------------|
| xyz-dev-init  | Does the Terraform module pulls and backend config                                 |
| xyz-dev-plan  | Runs a Terraform plan, creating a local TF plan file i.e. terraform-xyz-dev.tfplan |
| xyz-dev-apply | Does a Terraform apply using the created TF plan file                              |


## Post standup tasks
- Create the ci-user's access key if needed for CI/CD
	- `aws iam create-access-key --user-name dev-xyz`
- Enable PostgreSQL extensions and create DB users - see [here](./db.md)
- Seed the DB setting(s) tables
- Complete DNS config if needed - with external party
- Complete SMS provider configuration - if using an external SMS provider
- Over to the devs to manage the s/w deployments - needs to come after the DB configuration
- Configure monitoring - alarms/alerting/slack notifications etc. - outside the scope of this repo
