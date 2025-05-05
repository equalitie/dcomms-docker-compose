# Synapse

This directory will contain the generate configuration for Synapse.

`homeserver.yaml` is the configuration file for the Synapse homeserver, the back end for Matrix based chat. To view all available configuration options you can see the [official documents](https://element-hq.github.io/synapse/latest/usage/configuration/config_documentation.html).

## Synapse & email

It is recommended to configure an email account for Synapse, which can be used for email validation, and password resets. To do so, edit `homeserver.yaml` using the options available in the [official docs](https://element-hq.github.io/synapse/latest/usage/configuration/config_documentation.html#email), and then reload Synapse.

## Creating an admin user

To create an admin user use the command [register_new_matrix_user](https://manpages.debian.org/testing/matrix-synapse/register_new_matrix_user.1.en.html) within the `compose-synapse` Docker container. Example:

```
register_new_matrix_user -u dcomms-admin --admin -c /data/homeserver.yaml
```

## User registration and registration tokens

By default, Synapse is configured to require registration tokens to sign up. Synapse servers with open registrations are strongly discouraged, as they can result in severe spam and abuse. To generate a registration token you can follow the official API docs to [API access token](https://element-hq.github.io/synapse/latest/usage/administration/admin_api/index.html#making-an-admin-api-request), and then also to [generate a registration token](https://element-hq.github.io/synapse/latest/usage/administration/admin_api/registration_tokens.html). Example from cli of the dComms host:

```curl
user@dcomms-demo:~/dcomms-docker-compose# curl -X POST --header "Authorization: Bearer syt_abc123" http://localhost:8008/_synapse/admin/v1/registration_tokens/new -d '{}'
{"token":"abc123","uses_allowed":null,"pending":0,"completed":0,"expiry_time":null}
```

Once you have generated a registration token, this can be handed out to users and they can sign-up.
