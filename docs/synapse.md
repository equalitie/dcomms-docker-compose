# Synapse

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

## Mjolnir

Mjolnir is a mod tool for Synapse instances. We have included an example snippet and config for Mjolnir in conf/mjolnir/production.yaml and conf/compose/element.docker-compose.yml.

### Deploying

1. Register a mjolnir accounut as server admin. You can use one of the methods above.
2. Follow the steps in https://github.com/matrix-org/mjolnir/blob/main/docs/setup.md to retreive an access token
3. Populate the specified options in conf/mjolnir/production.yaml with your user and server information.
4. Uncomment the Mjolnir section in conf/compose/element.docker-compose.yml
5. Run `./run.sh` again.

You should now be able to follow the post-installation steps in https://github.com/matrix-org/mjolnir/blob/main/docs/setup.md#post-install

* Mjolnir docs https://github.com/matrix-org/mjolnir/blob/main/docs/setup.md
* Matrix.org mjolnir docs: https://matrix.org/docs/communities/moderation/

# Links
* Official docs: https://element-hq.github.io/synapse/latest/welcome_and_overview.html

