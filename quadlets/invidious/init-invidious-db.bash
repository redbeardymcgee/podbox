#!/bin/bash
set -eou pipefail

## NOTE:
## These should remain in sync with POSTGRES_USER && POSTGRES_DB in ./invidious.container
pguser=${1:-kemal}
pgdb=${2:-invidious}

## NOTE:
## `invidious-db` matches the volume name defined in ./invidious-db.volume
podman volume create invidious-db

podman run \
  --rm \
  -v invidious-db:/var/lib/postgresql/data \
  -e POSTGRES_USER=$pguser \
  -e POSTGRES_DB=$pgdb \
  --secret=invidious-db-pw,type=env,target=POSTGRES_PASSWORD \
  docker.io/library/postgres:14 \
  sh -c 'for initdb in channels videos channel_videos users session_ids nonces annotations playlists playlist_videos; do curl -s https://raw.githubusercontent.com/iv-org/invidious/refs/heads/master/config/sql/$initdb.sql | psql postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@localhost/$POSTGRES_DB'
