# podbox

## What is this?

This repository represents my preferred method of managing containers. These
are `quadlets`, which is an interface between `systemd` and `podman`.

- [Make `systemd` better for Podman with Quadlet](https://www.redhat.com/en/blog/quadlet-podman)

## Getting started

### Dependencies

- `podman>=4.3.0`
- `systemd`

### Quickstart

```bash
git clone  --depth=1 https://github.com/redbeardymcgee/podbox
cp -a "podbox/quadlets/$app" "$XDG_CONFIG_HOME/containers/systemd/"
# Edit the files in $XDG_CONFIG_HOME/containers/systemd/$app/ as needed
$EDITOR "$XDG_CONFIG_HOME/containers/systemd/$app/"*
systemctl --user daemon-reload
systemctl --user start "$app"
# Jump to the end of the logs to see if the app started
journalctl -e
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
- [x] [Actual](https://actualbudget.github.io/docs/)
- [ ] [Apprise](https://github.com/caronc/apprise)
- [ ] [Authelia](https://www.authelia.com/)
- [ ] [Authentik](https://goauthentik.io/)
- [ ] [betanin](https://github.com/sentriz/betanin)
- [ ] [Cabot](https://cabotapp.com/)
- [x] [Calibre](https://github.com/linuxserver/docker-calibre)
- [x] [Calibre-web](https://github.com/janeczku/calibre-web)
- [ ] [Code::Stats](https://codestats.net/)
- [ ] [dash.](https://getdashdot.com/)
- [ ] [Dittofeed](https://www.dittofeed.com)
- [ ] [Duplicacy](https://duplicacy.com/)
- [ ] [Duplicati](https://duplicati.com/)
- [ ] [EmulatorJS](https://emulatorjs.org/)
- [ ] [Foundry VTT](https://foundryvtt.com)
- [ ] [Gaseous](https://github.com/gaseous-project/gaseous-server)
- [ ] [glueforward](https://github.com/GeoffreyCoulaud/glueforward)
- [x] [gluetun](https://github.com/qdm12/gluetun)
- [ ] [Graphite](https://graphiteapp.org/)
- [ ] [Healthchecks](https://healthchecks.io/)
- [x] [Homarr](https://homarr.dev/)
- [ ] [Homepage](https://gethomepage.dev/)
- [x] [hoarder](https://hoarder.app/)
- [ ] [Keycloak](https://www.keycloak.org)
- [ ] [Komga](https://komga.org/)
- [ ] [LazyLibrarian](https://lazylibrarian.gitlab.io/)
- [ ] [Linkwarden](https://linkwarden.app/)
- [ ] [Miniflux](https://miniflux.app/)
- [ ] [n8n](https://n8n.io/)
- [ ] [Netbird](https://netbird.io/)
- [ ] [netboot.xyz](https://netboot.xyz)
- [ ] [Netdata](https://www.netdata.cloud/)
- [ ] [Notesnook](https://github.com/streetwriters/notesnook-sync-server)
- [ ] [ntop](https://www.ntop.org/)
- [ ] [OpenNMS](https://www.opennms.org/)
- [ ] [PiHole](https://pi-hole.net/)
- [ ] [Pod Arcade](https://www.pod-arcade.com/)
- [ ] [protonmail-bridge-docker](https://github.com/shenxn/protonmail-bridge-docker)
- [ ] [ProtonMailBridgeDocker](https://github.com/VideoCurio/ProtonMailBridgeDocker)
- [x] [Prowlarr](https://prowlarr.com)
- [x] [qBittorrent](https://qbittorrent.org)
- [x] [qbittorrent-port-forward-gluetun-server](https://github.com/mjmeli/qbittorrent-port-forward-gluetun-server)
- [x] [qbit_manage](https://github.com/StuffAnThings/qbit_manage)
- [x] [Radarr](https://radarr.video)
- [ ] [RomM](https://romm.app/)
- [ ] [Seafile](https://www.seafile.com)
- [ ] [Shiori](https://github.com/go-shiori/shiori)
- [ ] [solidtime](https://docs.solidtime.io/self-hosting/intro)
- [x] [Sonarr](https://sonarr.tv)
- [x] [Stirling PDF](https://stirlingpdf.io)
- [ ] [Supervisord](http://supervisord.org/)
- [x] [traggo](https://traggo.net)
- [ ] [Ubooquity](https://vaemendis.net/ubooquity/)
- [ ] [UrBackup](https://urbackup.org)
- [ ] [Vikunja](https://vikunja.io)
- [ ] [Wazuh](https://wazuh.com/)
- [ ] [wger](https://wger.de/)
- [ ] [Zenoss](https://www.zenoss.com/)
- [ ] [Zitadel](https://zitadel.com/)
