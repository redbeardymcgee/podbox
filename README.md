# podbox

## What is this?

I've been using docker compose to build and manage my *Jellyfin* server for
almost 2 years. I love what containerization enables but I am unhappy with `yaml`
as the language for expressing my system. I moved my personal desktop and
workstation pc to *NixOS* and have seen the light, but I am not sure that I
want to do containers under *NixOS* right now.

What I did want was a fully FOSS container stack. I have explored `podman` at
arm's length and finally discovered that there is a compose-like interface for
choreographing my containers, but it isn't `yaml`. It's actually `systemd`,
which has already been orchestrating service lifetimes even longer than
`docker` by three years!

This new declarative configuration is known as `quadlets`, and they are just
`systemd` unit files. I already run some of my own personal startup
applications as `systemd` user services, because it works across any window
manager or desktop environment. One autostart to rule them all, then.

The following sections of this document are my notes for building this system
from scratch, assuming you bring your own hardware. It should be easy to modify
them for another distribution if necessary. All notes and instructions are
commandline, because it's more universal and easier to copy & paste. I do not
know if there are GUI ways to do all of the necessary steps with *Cockpit* or a
hypervisor like *Proxmox*.

The end goal is make this a repository of `quadlet` stacks that are easy to
reuse. It would be similar to the `linuxserver.io` fleet, but I don't think
there is much need anymore for more custom containers. Many upstreams now
provide ready-built containers that we need only configure.

## Upcoming containers

- [x] [Caddy](https://caddyserver.com)
    - [ ] Socket activation (requires newer `caddy` and `podman`)
- [ ] [LazyLibrarian](https://lazylibrarian.gitlab.io/)
- [x] [Kavita](https://www.kavitareader.com/)
- [x] [Lounge](https://thelounge.chat)
- [ ] [netboot.xyz](https://netboot.xyz)
- [ ] [Actual](https://actualbudget.github.io/docs/)
- [ ] [librespeed](https://librespeed.org)
- [ ] [Graphite](https://graphiteapp.org/)
- [ ] [Cabot](https://cabotapp.com/)
- [ ] [ntop](https://www.ntop.org/)
- [x] [Glances](https://nicolargo.github.io/glances/)
- [ ] [Netdata](https://www.netdata.cloud/)
- [ ] [OpenNMS](https://www.opennms.org/)
- [ ] [Supervisord](http://supervisord.org/)
- [ ] [Zenoss](https://www.zenoss.com/)
- [ ] [Healthchecks](https://healthchecks.io/)
- [ ] [Dittofeed](https://www.dittofeed.com)
- [ ] [betanin](https://github.com/sentriz/betanin)
- [ ] [Apprise](https://github.com/caronc/apprise)
- [ ] [solidtime](https://docs.solidtime.io/self-hosting/intro)
- [x] [booktree](https://github.com/myxdvz/booktree)
- [ ] [LazyLibrarian](https://gitlab.com/LazyLibrarian/LazyLibrarian)
- [x] [Audiobookshelf](https://www.audiobookshelf.org/)
- [x] [Kavita](https://kavitareader.com)
- [ ] Calibre + [Calibre-web](https://github.com/janeczku/calibre-web)
- [ ] [Ubooquity](https://vaemendis.net/ubooquity/)
- [ ] [Komga](https://komga.org/)
- [x] [Kibitzr](https://kibitzr.github.io/)
- [ ] [ProtonMailBridgeDocker](https://github.com/VideoCurio/ProtonMailBridgeDocker)
- [ ] [protonmail-bridge-docker](https://github.com/shenxn/protonmail-bridge-docker)
- [ ] [Notesnook](https://github.com/streetwriters/notesnook-sync-server)
- [x] [Dashy](https://dashy.to)
- [ ] [Homarr](https://homarr.dev/)
- [ ] [Homepage](https://gethomepage.dev/)
- [ ] [Netbird](https://netbird.io/)
- [ ] [Seafile](https://www.seafile.com)
- [ ] [Keycloak](https://www.keycloak.org)
- [ ] [Authelia](https://www.authelia.com/)
- [ ] [Authentik](https://goauthentik.io/)
- [ ] [Zitadel](https://zitadel.com/)
- [ ] [Wazuh](https://wazuh.com/)
- [ ] [UrBackup](https://urbackup.org)
- [ ] [Duplicati](https://duplicati.com/)
- [ ] [Duplicacy](https://duplicacy.com/)
- [ ] [Stirling PDF](https://stirlingpdf.io)
- [ ] [Code::Stats](https://codestats.net/)

