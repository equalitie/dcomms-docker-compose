# Mastodon


## Creating an admin user

How to create an admin user can be found in the [admin cli documentation](https://docs.joinmastodon.org/admin/tootctl/). You will need to run these commands within the `compose-mastodon-web` docker container. Example:
```
tootctl accounts create dcomms-admin --email dcomms-admin@example.org --role Owner --confirmed --approved
```

This will display a automatically generated password that can be used on first login.


## Clearing media and regaining disk space

For speed and longevity of content, Mastodon caches images from remote servers indefinitly. Over time this can lead to significant storage usage of media that is unlikely to be retreived.
Mastodon provides a few cli commands to address this issue. Run commands from the [offical docs](https://docs.joinmastodon.org/admin/tootctl/#media) within the `compose-mastodon-web` docker container to reduce space. Example:
```
tootctl media remove --days 4
```


# Links

* Official docs https://docs.joinmastodon.org/
* A useful guide https://n00q.net/articles/guide-mastodon-hometown/
