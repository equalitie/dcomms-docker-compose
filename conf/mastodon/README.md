# Mastodon config directory

This directoy will store the generated env.production which contains the configuration for your dComms Mastodon deployment.
For more information about the Mastodon environment variables, please see the [official docs](https://docs.joinmastodon.org/admin/config/).

##  Mail

To configure mail, you will need to populate the following config options with information for an existing mail account:
```
SMTP_SERVER=
SMTP_PORT=
SMTP_LOGIN=
SMTP_PASSWORD=
SMTP_FROM_ADDRESS=
```
And depending on the SSL/TLS options available with your chosen mail provider, one or more of the following:
```
SMTP_ENABLE_STARTTLS=
SMTP_TLS=
SMTP_SSL=
```
