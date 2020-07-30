# Monitoring & Logging

The application uses **CloudWatch** for monitoring and logging. 

## Monitoring

See the [monitoring repo](https://github.com/nearform/covid-tracker-monitoring) for additional alarms and monitoring.

## Logs

Multiple log groups can be queried via `Logs Insights` selecting the proper log groups.

* *Find all responses with specific status code*

```
# API and PUSH service
# searching for all 5xx responses
fields @timestamp, @message
| filter res.statusCode like /5\d{2}/
| sort @timestamp desc
| limit 20
```

```
# API Gateway Access Logs
# searching for all 5xx responses
fields @timestamp, @message
| filter @message like /\"\s5\d{2}\s/
| sort @timestamp desc
| limit 20
```
