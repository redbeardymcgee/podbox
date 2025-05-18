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
> from scratch are located in [AlmaLinux.md](./AlmaLinux.md) or
> [Ubuntu.md](./Ubuntu.md
)

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

These services are on my radar for implementation. Please suggest your
favorites, and I welcome [pull
requests](https://git.mcgee.red/redbeardymcgee/podbox/pulls).

- [ ] [ArgoCD](https://github.com/argoproj/argo-cd)
- [ ] [Authelia](https://www.authelia.com/)
- [ ] [Authentik](https://goauthentik.io/)
- [ ] [Duplicacy](https://duplicacy.com/)
- [ ] [Duplicati](https://duplicati.com/)
- [ ] [Immich](https://immich.app/)
- [ ] [Keycloak](https://www.keycloak.org)
- [ ] [Netbird](https://netbird.io/)
- [ ] [Note Mark](https://github.com/enchant97/note-mark)
- [ ] [Notesnook](https://github.com/streetwriters/notesnook-sync-server)
- [ ] [Pod Arcade](https://www.pod-arcade.com/)
- [ ] [Seafile](https://www.seafile.com)
- [ ] [Shiori](https://github.com/go-shiori/shiori)
- [ ] [SimpleX](https://simplex.chat/)
- [ ] [solidtime](https://docs.solidtime.io/self-hosting/intro)
- [ ] [Ubooquity](https://vaemendis.net/ubooquity/)
- [ ] [Umami](https://umami.is/)
- [ ] [UrBackup](https://urbackup.org)
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
