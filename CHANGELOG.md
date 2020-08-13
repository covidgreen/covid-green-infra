# Change Log

All notable changes to this project will be documented in this file.

<a name="unreleased"></a>
## [Unreleased]

<a name="v0.1.1"></a>
## [v0.1.0] 2020-08-13
- Added: Added ability to set ECS image url and image tag overrides, this is based on @segfault's PR at https://github.com/covidgreen/covid-green-infra/pull/4
- Updated: Switched lambdas from using the AWSLambdaBasicExecutionRole to AWSLambdaVPCAccessExecutionRole managed policy
- Updated: Renamed the "root_profile" var and "root" AWS provider to "dns" as this is confusing, removed a redundant aws provider "root_us"
- Updated: Added changes @segfault added re explicit usage of the AWS CLI `--output json` usage in some of the scripts
- Removed: Removed Terraform validate from the pre-commit hook config as this is being used as a module, have left the s3 backend config for now
- Updated: Switched all the lambdas from nodejs10.x to nodejs12.x
- Added: Use variables for the lambda memory size and timeout attributes with defaults, so we can configure via env-vars files
- Removed: Extracted cti, gct and ni content into specific repos - Will not be managed by this repo
- Added: Added new AWS parameters certificate_audience and jwt_issuer and removed security_exposure_limit AWS parameter
- Added: Docs on the 2 approaches to managing a project - external to this repo and internal to this repo
- Added: Added RDS reader/writer endpoint outputs
- Added: Surfaced bastion ASG desired count as a variable, will need when we use this repo as a module
- Added: Switched to using path.module prefixes for the CloudWatch dashboard template and the ECS container defintion templates
- Fixed: Changed the create TF store backend script to cater for us-east-1 being a special case - Location constraints
- Fixed: Replace all refs to cti, gct and ni with xyz in docs and shell script comments - this is just prep for the open source branch
- Added: Added the following optional lambdas to the operators group execute list: daily-registrations-reporter, download and upload
- Added: Pre-commit hook to include TF fmt, validation and linting
- Fixed: Linting issues - no logic
- Added: Split RDS user usage so we no longer need to use the master credentials

<a name="v0.1.0"></a>
## [v0.1.0] 2020-08-13
- Initial content
