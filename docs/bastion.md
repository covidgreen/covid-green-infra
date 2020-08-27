# Bastion access
Will need to ensure the `bastion_enabled` variable is set to true - this is the default

The bastion uses an AutoScaling group with a desired_count = 0, min_count = 0 and max_count = 1

There is a schedule to scale down the bastions at 21:01 UTC each day - so your session may be terminated if connected ta this time

## Steps to connect
- So you will need to alter the ASG desired count to 1 on the AWS console and then allow sometime for the scaling to complete
- You should then be able to see the instance on the AWS console and can select and hit Connect -> Session Manager



# PostgreSQL client installation
The postgresql11 package will be installed using cloud-init, but if you need to install can use
```sudo amazon-linux-extras install postgresql11```


# Connecting to the Database
See the top of the [doc](./db.md) where it includes info on connecting using the RDS read_only_user
- The IAM operators group has access to AWS parameters and the AWS secret to allow this



# NOTES
- Anyone wishing to use the bastion will need to have an AWS account
- Will need to connect via the AWS console
- If we do an apply if a bastion instance is running it will be terminated as we will reset the desired count to 0
	- Can temp edit the bastion_asg_desired_count in the variables.tf file and set the desired_count to 1 to avoid this
- Since we use a data source to get the latest AWS Linux 2 AMI this may sometimes appear as change in the plan
