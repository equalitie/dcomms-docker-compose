# Docker

We don't do anything non-standard with Docker.

Configuration of the Docker container is defined in the docker-compose files, found in `conf/compose/SERVICE.docker-compose.yml`.

Aside from version upgrades, you will not usually need to edit the compose files.

## Updates

Deploying service upgrades is relatively easy. To keep track with updates we recommend either following the projects repositories on Github, or using their RSS/Atom feeds. See the links below for project release links.

An example of deploying Mastodon upgrades:

1. Replace all occurences of the version string (eg: `v4.3.6`) with the newer version (eg: `v4.3.8`) in the file `conf/compose/mastodon.docker-compose.yml`
2. Re-run `run.sh`


# Links
- Learn the Docker basics: https://docker-curriculum.com/
# Service releases
- Mastodon: https://github.com/mastodon/mastodon/releases
- Element: https://github.com/element-hq/element-web/releases
- Synapse: https://github.com/element-hq/synapse/releases
- Peertube: https://github.com/Chocobozzz/PeerTube/releases

