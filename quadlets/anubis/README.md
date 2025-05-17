# Anubis

## Necessary modifications

Ensure that `anubis.env` has at least set `REDIRECT_DOMAINS` and `TARGET`. The
target must be within the same container network as `anubis`, which should be
in the same network as your reverse-proxy such as `nginx` or `caddy`. You may
use multiple `Network` keys to achieve this.

## Optional

Create your `botPolicy.yaml` and uncomment `POLICY_FNAME` to supply your own
custom rules.

## Note

You will require a unique instance of Anubis for each domain you wish to
protect against AI crawlers.
