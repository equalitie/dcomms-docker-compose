# Deltachat

The current Deltachat docker image is running an outdated version of Deltachat. We are in the process of building support for Deltachat's chatmail server.

## Creating invite codes

From within the `compose-postfix` Docker container, you can generate a token up to a max of 999 days. Example:

```
$ mailadm add-token oneday --expiry 999d --prefix="tmp."
added token 'oneday'
token:oneday
  prefix = tmp.
  expiry = 999d
  maxuse = 50
  usecount = 0
  token  = 999d_xfw7y3mh5zs8t5m
  https://demo.dcomms.org/new_email?t=999d_xfw7y3mh5zs8t5m&n=oneday
  DCACCOUNT:https://demo.dcomms.org/new_email?t=999d_xfw7y3mh5zs8t5m&n=oneday
```

This can then be shared as a qr code, using the Linux `qrencode` command and the DCACCOUNT line on the host system. Example:

```
root@dcomms-demo:~/dcomms-docker-compose# qrencode -t UTF8 'DCACCOUNT:https://demo.dcomms.org/new_email?t=999d_xfw7y3mh5zs8t5m&n=oneday'
█████████████████████████████████████████
█████████████████████████████████████████
████ ▄▄▄▄▄ █▀ █▀▀▀▀█▀▀ █ ▄▄▄▄█ ▄▄▄▄▄ ████
████ █   █ █▀ ▄ ▀▀▄▀ ▄█▄ █▀▄██ █   █ ████
████ █▄▄▄█ █▀█ █ ▀▄  ▀▀  ▄▀▀▀█ █▄▄▄█ ████
████▄▄▄▄▄▄▄█▄█▄█ ▀ █▄▀▄▀▄█▄▀▄█▄▄▄▄▄▄▄████
████ ▄ ▄ ▀▄▄▄ ▄█▀██ ██▄█▀▀ ██ ▀▄▀▄█▄▀████
████▀▀▄▄▀▄▄██ ▀ █▄ █▀ ▄ ▀▀  ▄█▀ ▄▀█▀█████
████▀▀  ▄▄▄▀ ▄▀█▀█▄  █▄█▄▀█▀█    ▀█▄▄████
████▀█▀ ▀▀▄▀▄  ▀▄▄▀█▀ ▄ ▀▀▄ ▄▄▀▀▄  █▄████
████▀▄▄▄▀█▄█  ██▄█ ▄▄█▄█▄▀ ▀▀▄█▀▄▀  ▄████
██████▀▄█▄▄▄▄▄█▀▄ ▄▄▄▄▀▀▀██▀▄▄▀█▄  ▀ ████
████  ▄▀▀█▄▀ ▀▄███  ▄█▀█ ▀ █▄ █ █▀ ▀█████
████ █▀█▄█▄▀  ▄▀▄▄██ ▀█ ▀█▄▀▄▄▀█▄█  █████
████▄████▄▄█▀▀▀▀▄▄▄▄ ▄██ ▀▄█ ▄▄▄   ▄▀████
████ ▄▄▄▄▄ █▄ ▀ ▄ ▄▄▄ █▀▀▀▄  █▄█ ██▀█████
████ █   █ █ █ ▀█▄▄▄ █ ▀   ▄▄   ▄▀ ▄█████
████ █▄▄▄█ █ █▀ ▄ ▀▄ ▄▀▄ ▀ ▀▄ ██▀ ▀█▀████
████▄▄▄▄▄▄▄█▄▄▄███▄▄█▄██▄█▄▄██▄███▄██████
█████████████████████████████████████████
█████████████████████████████████████████
```

# Links

* Official docs: https://mailadm.readthedocs.io/en/latest/
