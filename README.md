# dcomms

Decentralized communications that work with or without the Internet

# Prerequisites
* `docker` using the docker guide (https://docs.docker.com/engine/install/)
* `curl`, `aria2`, `tor`
* A directory named `/var/www/dcomms` created on the host for the website document root.
* A subdomain with the A record pointed to the IP address of a node for automatic issuance of a Let's Encrypt SSL certificate.
* A subdomain with the MX record pointed to the A record of a node for DeltaChat mail delivery.
* (Optional) A Tor hidden service [configured](https://community.torproject.org/onion-services/setup/), and listening on port 80 and 8448.

# Hardware requirements
The system requirements will depend on several factors, including user-count, federation level, services and selecte, so we recommend choosing a system configuration that allows for the addition of resources.  
A bare minimum system running all services for a small number of users would require:
* 4GB RAM
* 2 Cores
* 50Gb disk

Whereas a deployment running all services for hundres of users would require:
* 16GB RAM
* 4 Cores
* 200Gb disk

The previous configuration could potentially scale to a user count of near 1000, if the level of user activity is low, however if each service is very active and federated then we recommend a minimum of:
* 32GB RAM
* 16 Cores
* 1TB disk

# Introduction

`dcomms` is a bundle of decentralized communication software running as services in the form of a docker swarm stack.

It is used to rapidly deploy a server hosting a variety of decentralized, encrypted, and federated communications platforms such as [Matrix](https://matrix.org/) and [DeltaChat](https://delta.chat) across multiple hosts.

Let's Encrypt TLS certificates are automatically issued and managed by the Caddy container across all services.

## Service containers

The dcomms stack leverages single node, non-replicated containers of the following services built from the latest images below:

* [CENO client](https://hub.docker.com/r/equalitie/ceno-client) courtesy of censorship.no
* [Synapse Docker](https://hub.docker.com/r/matrixdotorg/synapse/) courtesy of matrix.org
* [Element](https://hub.docker.com/r/vectorim/element-web/) courtesy of vector-im
* [Mau](https://mau.dev/maubot/maubot) courtesy of the maubot dev team
* [Caddy](https://hub.docker.com/_/caddy) courtesy of the Caddy Docker Maintainers
* [docker-mailadm](https://github.com/deltachat/docker-mailadm), includes dovecot and postfix, courtesy of DeltaChat
* [Mastodon](https://hub.docker.com/r/aphick/mastodon-sendmail), a modified version of the original Mastodon [container](https://hub.docker.com/r/tootsuite/mastodon) that includes sendmail.

## Ports

CENO: client: 28729/udp \
Caddy: (webserver): 443/tcp, 80/tcp, 8448/tcp \
DeltaChat: (postfix/dovecot): 587/tcp 143/tcp \
Synapse: 8448/tcp \
Peertube: 1935/tcp 1936/tcp (if livestreaming enabled)

* Note: `dcomms` leverages docker host networking and therefore we recommend denying access to all other unnecessary ports at the host level.

# Installation

[![asciicast](https://asciinema.org/a/9En7vMaopv2eWYf3T6W7saJh9.svg)](https://asciinema.org/a/9En7vMaopv2eWYf3T6W7saJh9)

Point the following A records to the docker worker you wish to use for deployment:
```
matrix.server1.example.org -> IP of your server
chat.server1.example.org -> IP of your server
peertube.server1.example.org -> IP of your server
server1.example.org -> IP of your server
```

Point the following MX record to the A record:
```
server1.example.org -> server1.example.org
```

Clone or download this repository.  Review `./install.sh` and make any that may be required for your environment.


## Install

Once your server meets the prerequisites, installation simply involves running `./install.sh` and responding to any prompts. Configs will be automatically placed in your `DCOMMS_DIR` and a `run.sh` script will be generated.

* Note: If you wish to reinstall dcomms you will need to delete all docker volumes, and the `conf` directory in `DCOMMS_DIR` before running `install.sh` again.

## Redeploy

In the future, if you need to start the dcomms containers again simply run the `./run.sh` program in your `DCOMMS_DIR`.

# Tor

If you wish to provide users with a Tor hidden service address by which they can access your services, you must first install and [configure Tor](https://community.torproject.org/onion-services/setup/).
The script will detect if you have Tor installed and prompt you for a hidden service address. You can find this in the `hostname` file in your `HiddenServiceDir`.

Example:
```
cat /var/lib/tor/onion_service/hostname
```

# Post installation

* Copy a pre-existing website into `/var/www/dcomms/` across all docker nodes or checkout all files from either the [dcomms-web repo (UA)](https://github.com/censorship-no/dcomms-web) or the [chatv3 repo (RU)](https://github.com/censorship-no/chatv3-web) into the same location.
* Optionally visit `https://server1.example.org` to view the website.
* Optionally visit `https://chat.server1.example.org` to view the Element service.
* Optionally configure a Matrix client to use `https://matrix.server1.example.org` as the homeserver.


# Troubleshooting

## Log review

## Altering configs

## Specific issues with services

