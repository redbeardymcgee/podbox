# podbox

## Table of Contents

- [What is this?](#what-is-this)
- [Table of Contents](#table-of-contents)
- [Getting started](#getting-started)
  - [Dependencies](#dependencies)
  - [Quickstart](#quickstart)
    - [Hello, world](#hello-world)
  - [Running real apps](#running-real-apps)
    - [Example](#example)
- [Coming soon](#coming-soon)
- [Acknowledgments](#acknowledgments)

## What is this?

[Make `systemd` better for Podman with Quadlet](https://www.redhat.com/en/blog/quadlet-podman)

This is a repository of ready-to-use `quadlets`. They allow you to run any
container with `podman` using `systemd` unit files in your user session.

This means no root user is ever invoked from the host system. Everything runs
under the same user permissions as yourself, from within your own `$HOME`.

> [!NOTE]
> It is recommended to create another user specifically for running these
> containers, but it is not strictly required. Details for setting up a system
> from scratch are located in [AlmaLinux.md](./AlmaLinux.md).

## Getting started

### Dependencies

- `podman>=4.3.0`
- `systemd`

You may need to add a large range of subuids and subgids, because `podman` will
use them when users are generated inside the containers.

```bash
sudo usermod --add-subuids 200000-299999 --add-subgids 200000-299999 $USER
```

### Quickstart

#### Hello, world

Create the following unit file at `~/.config/containers/systemd/helloworld.container`.

```ini
[Unit]
Description=Hello, world

[Service]
Restart=on-failure
TimeoutStartSec=900

[Install]
WantedBy=default.target

[Container]
Image=quay.io/podman/hello
ContainerName=helloworld
```

Run the following commands to load and run the container.

```bash
systemctl --user daemon-reload
systemctl --user start helloworld
journalctl -e
```

You should see the following in your journal!

```bash
Dec 01 08:42:05 perseus systemd[1362]: Started hello world.
Dec 01 08:42:05 perseus helloworld[1143334]: !... Hello Podman World ...!
Dec 01 08:42:05 perseus helloworld[1143334]:
Dec 01 08:42:05 perseus helloworld[1143334]:          .--"--.
Dec 01 08:42:05 perseus helloworld[1143334]:        / -     - \
Dec 01 08:42:05 perseus helloworld[1143334]:       / (O)   (O) \
Dec 01 08:42:05 perseus helloworld[1143334]:    ~~~| -=(,Y,)=- |
Dec 01 08:42:05 perseus helloworld[1143334]:     .---. /`  \   |~~
Dec 01 08:42:05 perseus helloworld[1143334]:  ~/  o  o \~~~~.----. ~~
Dec 01 08:42:05 perseus helloworld[1143334]:   | =(X)= |~  / (O (O) \
Dec 01 08:42:05 perseus helloworld[1143334]:    ~~~~~~~  ~| =(Y_)=-  |
Dec 01 08:42:05 perseus helloworld[1143334]:   ~~~~    ~~~|   U      |~~
Dec 01 08:42:05 perseus helloworld[1143334]:
Dec 01 08:42:05 perseus helloworld[1143334]: Project:   https://github.com/containers/podman
Dec 01 08:42:05 perseus helloworld[1143334]: Website:   https://podman.io
Dec 01 08:42:05 perseus helloworld[1143334]: Desktop:   https://podman-desktop.io
Dec 01 08:42:05 perseus helloworld[1143334]: Documents: https://docs.podman.io
Dec 01 08:42:05 perseus helloworld[1143334]: YouTube:   https://youtube.com/@Podman
Dec 01 08:42:05 perseus helloworld[1143334]: X/Twitter: @Podman_io
Dec 01 08:42:05 perseus helloworld[1143334]: Mastodon:  @Podman_io@fosstodon.org
```

### Running real apps

1. Copy the `quadlets/$app/` you want to run to
   `$XDG_CONFIG_HOME/containers/systemd/quadlets/`
2. Edit the files to match your system
    - Set your `Network=...` for containers that need to share a network
    namespace
    - Set `Volume=...:...` to a path that exists on your system if you need to
    access it within that container
    - Modify environment variables with `Environment=...` or use an env file with `EnvironmentFile=./path/to/foo.env`
3. Load the updated container definition into `systemd`
4. Launch the container

#### Example

```bash
# Step 1
git clone --depth=1 https://github.com/redbeardymcgee/podbox
cp -a podbox/quadlets/thelounge "$XDG_CONFIG_HOME"/containers/systemd/
# Step 2
$EDITOR "$XDG_CONFIG_HOME"/containers/systemd/thelounge/*
# Step 3
systemctl --user daemon-reload
# Step 4
systemctl --user start thelounge
```

Navigate to `http://localhost:9000` in your browser.

> [!WARNING]
> If the application is not found, confirm that the service is listening on
> port 9000 with `ss -tunlp`. You should see something similar to the
> following in your output:
> 
> ```bash
> Netid State  Recv-Q Send-Q Local Address:Port  Peer Address:PortProcess
> tcp   LISTEN 0      4096       *:9000           *:*   users:(("rootlessport",pid=913878,fd=10))
> ```

## Coming soon

I'm working on new quadlets every day. This is a list of all of the containers
that I intend to add to this repository. It is still growing, and I welcome
[pull requests](https://github.com/redbeardymcgee/podbox/pulls).

- [x] [Actual](https://actualbudget.github.io/docs/)
- [x] [AdGuard](https://adguard.com)
- [ ] [Apprise](https://github.com/caronc/apprise)
- [ ] [ArgoCD](https://github.com/argoproj/argo-cd)
- [x] [Audiobookshelf](https://www.audiobookshelf.org/)
- [ ] [Authelia](https://www.authelia.com/)
- [ ] [Authentik](https://goauthentik.io/)
- [ ] [betanin](https://github.com/sentriz/betanin)
- [ ] [Bigcapital](https://bigcapital.app/)
- [ ] [Bitwarden](https://bitwarden.com/)
- [x] [Blinko](https://blinko.mintlify.app/introduction)
- [x] [booktree](https://github.com/myxdvz/booktree)
- [x] [Caddy](https://caddyserver.com) # Socket activation requires newer `caddy` and `podman`
- [x] [Calibre](https://github.com/linuxserver/docker-calibre)
- [x] [Calibre-web](https://github.com/janeczku/calibre-web)
- [x] [ChartDB](https://chartdb.io/)
- [ ] [Checkmate](https://github.com/bluewave-labs/checkmate)
- [ ] [Code::Stats](https://codestats.net/)
- [x] [dash.](https://getdashdot.com/)
- [x] [Dashy](https://dashy.to)
- [ ] [Dittofeed](https://www.dittofeed.com)
- [ ] [Duplicacy](https://duplicacy.com/)
- [ ] [Duplicati](https://duplicati.com/)
- [ ] [EmulatorJS](https://emulatorjs.org/)
- [x] [Filebrowser](https://filebrowser.org/)
- [x] [FiveFilters](https://www.fivefilters.org/)
- [x] [Foundry VTT](https://foundryvtt.com)
- [x] [FreshRSS](https://www.freshrss.org/)
- [ ] [Gaseous](https://github.com/gaseous-project/gaseous-server)
- [x] [Glances](https://nicolargo.github.io/glances/)
- [ ] [glueforward](https://github.com/GeoffreyCoulaud/glueforward)
- [x] [gluetun](https://github.com/qdm12/gluetun)
- [ ] [Graphite](https://graphiteapp.org/)
- [ ] [Healthchecks](https://healthchecks.io/)
- [x] [hoarder](https://hoarder.app/)
- [x] [Homarr](https://homarr.dev/)
- [ ] [Homepage](https://gethomepage.dev/)
- [ ] [Immich](https://immich.app/)
- [x] [IT-Tools](https://it-tools.tech/)
- [x] [Joplin](https://joplinapp.org/)
- [x] [Kavita](https://kavitareader.com)
- [ ] [Keycloak](https://www.keycloak.org)
- [x] [Kibitzr](https://kibitzr.github.io/)
- [ ] [Komga](https://komga.org/)
- [ ] [LazyLibrarian](https://lazylibrarian.gitlab.io/)
- [x] [librespeed](https://librespeed.org)
- [x] [Linkwarden](https://linkwarden.app/)
- [x] [Lounge](https://thelounge.chat)
- [x] [Matrix](https://matrix.org/)
- [ ] [Maxun](https://github.com/getmaxun/maxun)
- [x] [Mealie](https://mealie.io/)
- [x] [Memos](https://usememos.com)
- [ ] [Miniflux](https://miniflux.app/)
- [x] [MinIO](https://min.io)
- [ ] [n8n](https://n8n.io/)
- [x] [Nebula](https://github.com/slackhq/nebula)
- [ ] [Netbird](https://netbird.io/)
- [x] [netboot.xyz](https://netboot.xyz)
- [x] [Netdata](https://www.netdata.cloud/)
- [ ] [Note Mark](https://github.com/enchant97/note-mark)
- [ ] [Notesnook](https://github.com/streetwriters/notesnook-sync-server)
- [ ] [ntop](https://www.ntop.org/)
- [ ] [OpenNMS](https://www.opennms.org/)
- [ ] [PiHole](https://pi-hole.net/)
- [ ] [Pocket ID](https://github.com/stonith404/pocket-id)
- [ ] [Pod Arcade](https://www.pod-arcade.com/)
- [ ] [Postiz](https://postiz.com/)
- [x] [Prometheus](https://prometheus.io)
- [x] [protonmail-bridge-docker](https://github.com/shenxn/protonmail-bridge-docker)
- [x] [Prowlarr](https://prowlarr.com)
- [x] [qbit_manage](https://github.com/StuffAnThings/qbit_manage)
- [x] [qBittorrent](https://qbittorrent.org)
- [x] [qbittorrent-port-forward-gluetun-server](https://github.com/mjmeli/qbittorrent-port-forward-gluetun-server)
- [x] [Radarr](https://radarr.video)
- [ ] [RomM](https://romm.app/)
- [ ] [Seafile](https://www.seafile.com)
- [ ] [Shiori](https://github.com/go-shiori/shiori)
- [ ] [SimpleX](https://simplex.chat/)
- [x] [Snowflake](https://snowflake.torproject.org/)
- [ ] [solidtime](https://docs.solidtime.io/self-hosting/intro)
- [x] [Sonarr](https://sonarr.tv)
- [x] [Stirling PDF](https://stirlingpdf.io)
- [ ] [Supervisord](http://supervisord.org/)
- [x] [Tandoor](https://github.com/TandoorRecipes/recipes)
- [x] [traggo](https://traggo.net)
- [ ] [Ubooquity](https://vaemendis.net/ubooquity/)
- [ ] [Umami](https://umami.is/)
- [ ] [UrBackup](https://urbackup.org)
- [ ] [Vikunja](https://vikunja.io)
- [ ] [Wazuh](https://wazuh.com/)
- [ ] [wiki.js](https://js.wiki)
- [ ] [wger](https://wger.de/)
- [ ] [Zenoss](https://www.zenoss.com/)
- [ ] [Zitadel](https://zitadel.com/)

## Acknowledgments

Thanks to these users for their examples and contributions!

- [@fpatrick](https://github.com/fpatrick)/[podman-quadlet](https://github.com/fpatrick/podman-quadlet)
- [@dwedia](https://github.com/dwedia)/[podmanQuadlets](https://github.com/dwedia/podmanQuadlets)
- [@sudo-kraken](https://github.com/sudo-kraken)
- [@EphemeralDev](https://github.com/EphemeralDev)
