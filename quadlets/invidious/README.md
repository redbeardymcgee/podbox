# Invidious

## Secret keys

`HMAC_KEY` is added to the config.yml, so cannot be encoded as a secret.

`SERVER_SECRET_KEY` is an environment variable, so is encoded within a podman
secret but is required in `config.yml` because there is no builtin support for secrets in yaml. I'm not sure this is a real env var.

`POSTGRES_PASSWORD` is also a podman secret, like every other quadlet, but must
be entered as plaintext in `config.yml`.

> [!NOTE]
> The [community installation
> guide](https://docs.invidious.io/community-installation-guide/#podman-via-systemd)
> implies that these may be env vars without needing the `config.yml` values, but
> it is outdated to the degree that it doesn't set up the companion container
