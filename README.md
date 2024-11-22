# podbox

## What is this?

This repository represents my preferred method of managing containers. These
are `quadlets`, which is an interface between `systemd` and `podman`.

- [Make `systemd` better for Podman with Quadlet](https://www.redhat.com/en/blog/quadlet-podman)

## Getting started

### Dependencies

- `podman>=4.3.0`
- `systemd`

### How to use these files

Copy the `$application` directory from this repository that you want to run
into `/home/$ctuser/.config/containers/systemd/`. Make any necessary changes to
the files within this directory to match your system and needs, such as
pointing a volume path at a different mount point or filling in any
`$variables`.

```bash
systemctl --user start $application
journalctl -e # jump to the end of the logs to see if the app started
```

## Upcoming containers

- [x] [Audiobookshelf](https://www.audiobookshelf.org/)
- [x] [booktree](https://github.com/myxdvz/booktree)
- [x] [Caddy](https://caddyserver.com) # Socket activation requires newer `caddy` and `podman`
- [x] [Dashy](https://dashy.to)
- [x] [Glances](https://nicolargo.github.io/glances/)
- [x] [Kavita](https://kavitareader.com)
- [x] [Kibitzr](https://kibitzr.github.io/)
- [x] [librespeed](https://librespeed.org)
- [x] [Lounge](https://thelounge.chat)
- [ ] [Actual](https://actualbudget.github.io/docs/)
- [ ] [Apprise](https://github.com/caronc/apprise)
- [ ] [Authelia](https://www.authelia.com/)
- [ ] [Authentik](https://goauthentik.io/)
- [ ] [betanin](https://github.com/sentriz/betanin)
- [ ] [Cabot](https://cabotapp.com/)
- [ ] [Calibre](https://github.com/linuxserver/docker-calibre)
- [ ] [Calibre-web](https://github.com/janeczku/calibre-web)
- [ ] [Code::Stats](https://codestats.net/)
- [ ] [Dittofeed](https://www.dittofeed.com)
- [ ] [Duplicacy](https://duplicacy.com/)
- [ ] [Duplicati](https://duplicati.com/)
- [ ] [Foundry VTT](https://foundryvtt.com)
- [ ] [glueforward](https://github.com/GeoffreyCoulaud/glueforward)
- [ ] [Graphite](https://graphiteapp.org/)
- [ ] [Healthchecks](https://healthchecks.io/)
- [ ] [Homarr](https://homarr.dev/)
- [ ] [Homepage](https://gethomepage.dev/)
- [ ] [Keycloak](https://www.keycloak.org)
- [ ] [Komga](https://komga.org/)
- [ ] [LazyLibrarian](https://lazylibrarian.gitlab.io/)
- [ ] [Netbird](https://netbird.io/)
- [ ] [netboot.xyz](https://netboot.xyz)
- [ ] [Netdata](https://www.netdata.cloud/)
- [ ] [Notesnook](https://github.com/streetwriters/notesnook-sync-server)
- [ ] [ntop](https://www.ntop.org/)
- [ ] [OpenNMS](https://www.opennms.org/)
- [ ] [protonmail-bridge-docker](https://github.com/shenxn/protonmail-bridge-docker)
- [ ] [ProtonMailBridgeDocker](https://github.com/VideoCurio/ProtonMailBridgeDocker)
- [ ] [Seafile](https://www.seafile.com)
- [ ] [solidtime](https://docs.solidtime.io/self-hosting/intro)
- [ ] [Stirling PDF](https://stirlingpdf.io)
- [ ] [Supervisord](http://supervisord.org/)
- [ ] [Ubooquity](https://vaemendis.net/ubooquity/)
- [ ] [UrBackup](https://urbackup.org)
- [ ] [Vikunja](https://vikunja.io)
- [ ] [Wazuh](https://wazuh.com/)
- [ ] [Zenoss](https://www.zenoss.com/)
- [ ] [Zitadel](https://zitadel.com/)
