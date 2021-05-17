<img alttext="COVID Green Logo" src="https://raw.githubusercontent.com/lfph/artwork/master/projects/covidgreen/stacked/color/covidgreen-stacked-color.png" width="300" />

# Terraform

## Diagrams

All diagrams are created using [draw.io](https://draw.io)/[diagrams.net](https://app.diagrams.net/), you can import the XML and modify it.

### Application

![application diagram](./docs/CovidTrackerIreland-Application.png "Application diagram")

### Networking

![network diagram](./docs/CovidTrackerIreland-Network.png "Network diagram")

The network is composed by a main VPC and 3 subnets:

1. `public` for application load balancers and nat gateways
2. `private` for push notification fargate service
3. `intra` for api fargate service

External connectivity via NAT Gateways is allowed just from the `private` subnet. To be able to communicate with AWS services from the `intra` subnet we make use of VPC Endpoints.

The RDS Aurora cluster is avilable to both `private` and `intra` subnets.

## Development

We use a git pre-commit hook to do some checks and linting, see the top of [.pre-commit-config.yaml](./.pre-commit-config.yaml) for installation instructions

You need first to set up AWS profiles locally for every AWS account/project/environment you're going to work on. Once done change it in the project/environment variables override files in `env-vars`. The project uses 2 different AWS profiles, one to manage the infrastructure and one to manage DNS entries. This is because the AWS account used to spin up an environments could be different from the account from where the DNS zone is registered.

See [Creating a new project](./docs/creating-a-new-project.md) for setting up the Terraform backend setup.

Make file usage
```
# Using the xyz project and dev environment
make xyz-dev-init
make xyz-dev-plan
make xyz-dev-apply
```

Every `terraform` command can be launched via the `Makefile`, it will take care of initializing the folder to use different backends, planning, applying, and destroying changes.

### Change log

We maintain a change log [here](./CHANGELOG.md)

### Note
Sometimes on the plan/apply change(s) will appear for the bastions
- The bastion AMI is based on using the latest **Amazon Linux 2** AMI - this is fine to apply and will not terminate any running instances
- The bastion ASG count will show a change from 1 -> 0, this is due to someone having a bastion instance running, in this case you do not want to terminate their instance
	- Easiest thing to do is alter your local bastion.tf **desired_capacity = 1** and re-run the plan, this way the instance will remain running and this change will no longer appear in the plan

## Lambdas
### authorizer
Checks a JWT is valid when the Gateway tried to access items in the S3 bucket.

### callback
Used to collect symptom info from the app from an SQS queue. Currently unused.

### cleanup
Handles removal of expired data from the database, and collects daily registration counts into a REGISTER metric.

### cso - Optional
This lambda is specific to the Irish app and compiles symptom info into a CSV file. The file is then encrypted using GPG (symmetric key in Secrets) and then uploaded via SFTP to the Central Statistics Office in Ireland. This is obviously not used in Gibraltar.

### daily-registrations-reporter - Optional
This lambda is currently specific to the Gibraltar app and generates a report of cumulative API registrations by day for the app, which it sends to an SNS topic.

### download - Optional
This lambda is for environments involved in testing the interoperability service. Downloads any new batches of exposure keys from the interop service since the lambda last ran, and stores them ready to be included in future export files.

### exposures
Generates exposure files in zip format for the S3 bucket. Those files contain the encrypted contact tracing information the phone API uses to determine if you have had a close contact with someone. This lambda runs on a schedule, selecting the exposure info from the database and making the archive available once complete.

### settings
This lambda is used to generate a settings.json file which contains values that can override the app defaults.
This saves us having to go through a full App Store release cycle to change minor details like phone numbers etc.

### sms
This lambda is triggered by the SMS SQS queue, and allows project specific handling of sending SMS via different providers.

### stats
This lambda is used to generate a daily stats.json file from a web service run by the Central Statistics Office in Ireland.
This info is used in the Irish app to power various graphs and info screens.

### token
This lambda is used to generate tokens for testing. It is not used by clients or end users. The phone app and backend APIs make use of a service called Device check which validates that we are talking to an actual device. To get around this for testing, we have a lambda that can generate two different kinds of token, one for register and one for push. The register token allows you to bypass the checks in the backend API and the push token works for the push API service.

### upload - Optional
This lambda is for environments involved in testing the interoperability service. Uploads any new exposure keys to the interop service, ready for other back-ends to download.

## AWS secrets and parameters
Secrets are stored in AWS Secrets Manager, these are populated outside of this Terraform content.
- Some are optional as they are not used by all instances

Parameters are stored in AWS System Manager, these are populated by content in this repository
- Some are optional as they are not used by all instances

## Notes

All the infrastructure set up is automated but not secrets that need to be created manually. The current list of secrets used by the app can be found in the `main.tf` file or in the Secrets Manager UI via AWS Console.

## Additional documentation

* [Creating a new project](./docs/creating-a-new-project.md)
* [Project env-vars](./env-vars/README.md)
* [Data disaster recovery plan](./docs/drp-data.md)
* [Monitoring & Logging](./docs/monitoring.md)
* [Bastion access](./docs/bastion.md)

## Team

### Lead Maintainers

* @colmharte - Colm Harte <colm.harte@nearform.com>
* @jasnell - James M Snell <jasnell@gmail.com>
* @aspiringarc - Gar Mac Críosta <gar.maccriosta@hse.ie>

### Core Team

* @ShaunBaker - Shaun Baker <shaun.baker@nearform.com>
* @jackmurdoch - Jack Murdoch <jack.murdoch@nearform.com>
* @pmcgrath - Pat McGrath <pat.mcgrath@nearform.com>
* @zimny - Piotr Zimoch <piotr.zimoch@nearform.com>
* @dgonzalez - David Gonzalez <david.gonzalez@nearform.com>
* @ninjatux - Valerio Barrila <valerio.barrila@nearform.com>

### Contributors
* @floridemai - Paul Negrutiu <paul.negrutiu@nearform.com>
* @jackdclark - Jack Clark <jack.clark@nearform.com>
* @andreaforni - Andrea Forni <andrea.forni@nearform.com>
* @fiacc - Fiac O'Brien Moran <fiacc.obrienmoran@nearform.com>
* @daynelucas - Dayne Lucas <dayne.lucas@nearform.com>
* @mb2con - Matt Bernard <matt.bernard@nearform.com>

### Past Contributors

* @segfault - Mark Guzman <segfault@hasno.info>
* @dennisgove - Dennis Gove <dgove1@bloomberg.net>
* @dharding - David J Harding <davidjasonharding@gmail.com>

## Hosted By

<a href="https://www.lfph.io"><img alttext="Linux Foundation Public Health Logo" src="https://raw.githubusercontent.com/lfph/artwork/master/lfph/stacked/color/lfph-stacked-color.svg" width="200"></a>

[Linux Foundation Public Health](https://www.lfph.io)

## Acknowledgements

<a href="https://www.hse.ie"><img alttext="HSE Ireland Logo" src="https://www.hse.ie/images/hse.jpg" width="200" /></a><a href="https://nearform.com"><img alttext="NearForm Logo" src="https://openjsf.org/wp-content/uploads/sites/84/2019/04/nearform.png" width="400" /></a>

## License

Copyright (c) 2020 HSEIreland
Copyright (c) The COVID Green Contributors

[Licensed](LICENSE) under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
