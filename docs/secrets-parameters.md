### AWS Secrets Manager Secrets
Secrets are not managed by the Terraform content.

Secrets use a prefix ENV-NAMESPACE- in their names.

- Some secrets are used by all projects
	- device-check
	- encrypt
	- exposures
	- header-x-secret
	- jwt
	- rds
- Some are optional
	- cct
	- cso
	- interop
	- sms

Optional secrets need to be added to the option_secrets variable.

You can use the [aws-secrets.sh](../scripts/aws-secrets.sh) script to create secrets.

i.e. For **dev** env and **ni** project namespace
```
./scripts/aws-secrets.sh create dev-xyz-device-check 'SOME-VALUE'
```


### AWS Systems Manager Parameters
Parameters are managed by the Terraform content.

- Some are optional
	- arcgis_url
	- daily_registrations_reporter_email_subject
	- daily_registrations_reporter_sns_arn


### Generation of Secret Values

#### device-check secret
The `device-check` secret is used to configure device verification, which is performed via DeviceCheck on iOS and SafetyNet on Android.

The format for the secret is as follows:
```json
{
  "apkCertificateDigestSha256":"",
  "apkDigestSha256":"",
  "apkPackageName":"DNS-NAME",
  "key":"-----BEGIN PRIVATE KEY-----\nKEY-VALUE\n-----END PRIVATE KEY-----",
  "keyId":"Key Id",
  "safetyNetRootCa":"-----BEGIN CERTIFICATE-----\nCERTIFICATE-VALUE\n-----END CERTIFICATE-----",
  "teamId":"Team Id",
  "timeDifferenceThresholdMins": MINS
}
```
##### apkCertificateDigestSha256
An array of SHA-265 hashes of the certificates used to sign the APK. Can be set to a false value to disable the check.

##### apkDigestSha256
The SHA-256 hash of the APK file. Can be set to a false value to disable the check and should be set to false if there are multiple
supported versions deployed.

##### apkPackageName
The name of the APK package.

##### key
Private key for the DeviceCheck API (obtained from Apple).

##### keyId
The ID of the key for the DeviceCheck API (obtained from Apple).

##### safetyNetRootCa
The GlobalSign Root R2 public key used to verify the certificate chain when validating SafetyNet attestations, obtained from https://pki.goog/.

##### teamId
The team ID for the DeviceCheck API (obtained from Apple).

##### timeDifferenceThresholdMins
Maximum time difference (in minutes) between the verification on the device and the server timestamp, used to detect incorrectly configured phone
times which can cause verification errors with DeviceCheck.

#### encrypt Secret
The `encrypt` secret is used to symmetrically encrypt the token refresh value stored in the database using aes-256-cbc. It is also used to verify it when presented later.

The secret value should be a random string 32 characters in length.

The format of the secret is as follows:
```json
{
  "key": "32 random characters"
}
```

#### exposures Secret
The `exposures` secret is used to sign the exposure payloads downloaded by the apps to verify their authenticity.
The exposures public key is sent to Apple (and Google?) to be stored on a central key server. Phones can fetch the relevant key to verify data presented to the contact tracing API and will reject processing on anything that fails signature verification.

The format of the secret is as follows:
```json
{
  "privateKey": "-----BEGIN EC PRIVATE KEY-----\nKEY-VALUE\n-----END EC PRIVATE KEY-----",
  "signatureAlgorithm": "1.2.840.10045.4.3.2",
  "verificationKeyId": "266",
  "verificationKeyVersion": "v1"
}
```

##### privateKey
This can be generated using OpenSSL with the following command:

```sh
openssl ecparam -out key.pem -name prime256v1 -genkey -noout
cat key.pem

-----BEGIN EC PRIVATE KEY-----
aegsyrudiklhNUIBRWHK ... truncated.
-----END EC PRIVATE KEY-----
```

You can derive the public key component using this command:

```sh
openssl ec -in key.pem -pubout -out public.pem
cat public.pem

-----BEGIN PUBLIC KEY-----
DWAGHDRJSBACfgwhejte ... truncated.
-----END PUBLIC KEY-----
```

The new lines present in the private key value are a common source of problems. Make sure you carefully replace each one with a single `\n` character.

##### signatureAlgorithm
This should always be the string `1.2.840.10045.4.3.2` which identifies the signing algorithm (SHA-256 with ECDSA). Its value comes from RFC-7427 https://tools.ietf.org/html/rfc7427#appendix-A.3.2

##### verificationKeyId
This value should be the Mobile Country Code of the Country the app will be used in. For example, 266 is the code for Gibraltar.
You can look these values up here: https://en.wikipedia.org/wiki/Mobile_country_code

##### verificationKeyVersion
This should always be `v1` as the server signing key is not rotated.

#### header-x-secret Secret
The `header-x-secret` secret is used to secure communication between the APIGateway and ALB for the API traffic.

The secret value should be a random alphanumeric string 96 characters in length.

The format of the secret is as follows:
```json
{
  "header-secret":"Some random 96 alpanumeric characters"
}
```

#### jwt Secret
The `jwt` secret is used for signing the JSON Web Tokens with the HMAC algorithm. These are issued to users for API authentication,
and the signature is checked by the service to ensure their legitimacy.

The secret value should be a random string 32 characters in length.

The format of the secret is as follows:
```json
{
  "key": "32 random characters"
}
```

#### rds Secret
The `rds` secret contains the master RDS credentials.

The format of the secret is as follows:
```json
{
  "password":"A strong password",
  "username":"rds_admin_user"
}
```
