#!/usr/bin/env bash

set -eou pipefail

## NOTE: Depends on podman secret `invidious-db-pw`
systemctl --user start invidious-db

podman exec invidious-db
  sh -c '
        apt-get update
        apt-get install --assume-yes --no-install-recommends curl

        for initdb in channels videos channel_videos users session_ids nonces annotations playlists playlist_videos
        do
          curl -s https://raw.githubusercontent.com/iv-org/invidious/refs/heads/master/config/sql/$initdb.sql | psql postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@invidious-db/$POSTGRES_DB
        done
        apt-get --assume-yes purge curl
        '

systemctl --user stop invidious-db
