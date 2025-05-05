# Element and Synapse config directory

This directory contains the generated config files for Element-web and the Synapse homeserver.

## Element-web

`config.json` is the configuration file for Element-web, the web front-end for Matrix chat. Available options can be found in the [official repository](https://github.com/element-hq/element-web/blob/develop/docs/config.md).

## Matrix

`homeserver.yaml` is the configuration file for the Synapse homeserver, the back end for Matrix based chat. To view all available configuration options you can see the [official documents](https://element-hq.github.io/synapse/latest/usage/configuration/config_documentation.html).

### Synapse & email

It is recommended to configure an email account for Synapse, which can be used for email validation, and password resets. To do so, edit `homeserver.yaml` using the options available in the [official docs](https://element-hq.github.io/synapse/latest/usage/configuration/config_documentation.html#email), and then reload Synapse.
