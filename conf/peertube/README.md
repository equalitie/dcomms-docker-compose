# Peertube

This directory contains the environment variables for your dComms Peertube instance. More information about available parameters can be found in the [official docs](https://docs.joinpeertube.org/maintain/configuration).

## Email

By default email is not configured on a deployed dComms peertube instance. To configure email, populate or edit the following variables then re-run `run.sh`:

```
PEERTUBE_SMTP_HOSTNAME=
PEERTUBE_SMTP_PORT=475
PEERTUBE_SMTP_FROM=
PEERTUBE_SMTP_TLS=true
PEERTUBE_SMTP_DISABLE_STARTTLS=true
PEERTUBE_ADMIN_EMAIL=changeme@example.com
```

# Links
- Create first admin user: https://docs.joinpeertube.org/install/any-os#administrator
