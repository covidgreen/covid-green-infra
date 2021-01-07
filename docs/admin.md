# Admin Web App

## Requirements

### DNS Root Record for Cognito

In order to configure cognito, a DNS Root `A` record **must** be set on domain's DNS table. 

Any target will work, even a fake IP address, Cognito must see that this record is just _present_.
