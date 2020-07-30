# Checklist
Using a project with key **xyz** and a **dev** environment.


## Create an AWS profile
Add a xyz-dev profile to ~/.aws/credentials


## Create the infra CI user - admin privs by default
See [../scripts/create-infra-ci-user.sh] script

```
# Set your AWS_PROFILE
export AWS_PROFILE=xyz-dev

# Create
./scripts/create-infra-ci-user.sh dev-xyz

# Grab the sensitive infra ci user credentials and configure in the CI system - these are VERY sensitive so treat with care
```


## Create the Terraform state backend
See [../scripts/create-tf-state-backend.sh] script

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


## Create the env-vars files

| File                    | Content                                                    |
| ------------------------| -----------------------------------------------------------|
| env-vars/cti.tfvars     | Contains the CTI values that are the same across all envs  |
| env-vars/xyz-dev.tfvars | Contains the CTI values that are specific to the dev env   |

With these we need to decide on some optionals
- Enable DNS where we manage the DNS, in some cases we do not manage the DNS
- Enable TLS certificates where we manage the certificates, in some cases we need to import certificates
- Some lambdas are optional
- Some secrets/parameters are optional


## Slack channel/application
May need to create a slack application/channel - usually for the prod env only at this time.
- Application will be PROJECT-bot i.e. xyz-bot
- Channel name will be PROJECT-contact-tracing-alarms i.e ctii-contact-tracing-alarms


## Create the Makefile targets
Will need to create the following targets.

| Target        | Description                                                                        |
| --------------| -----------------------------------------------------------------------------------|
| xyz-dev-init  | Does the Terraform module pulls and backend config                                 |
| xyz-dev-plan  | Runs a Terraform plan, creating a local TF plan file i.e. terraform-xyz-dev.tfplan |
| xyz-dev-apply | Does a Terraform apply using the created TF plan file                              |


## Post standup tasks
- Seed the DB setting(s) tables
- Create DB users - see [here](./db.md)
- Complete DNS config if needed - with external party
- Complete SMS provider configuration - if using an external SMS provider
