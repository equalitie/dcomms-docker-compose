# Synapse

This directory will contain the generate configuration for Synapse.

`homeserver.yaml` is the configuration file for the Synapse homeserver, the back end for Matrix based chat. To view all available configuration options you can see the [official documents](https://element-hq.github.io/synapse/latest/usage/configuration/config_documentation.html).

## Synapse & email

It is recommended to configure an email account for Synapse, which can be used for email validation, and password resets. To do so, edit `homeserver.yaml` using the options available in the [official docs](https://element-hq.github.io/synapse/latest/usage/configuration/config_documentation.html#email), and then reload Synapse.
