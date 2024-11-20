# podbox

![Connectable status](./resource/image/connectable-status.png)

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

## Operating System

My proof of concept server running this container stack is built on AlmaLinux
9.4. `podman` and `systemd` with `quadlet` support is required if you are using another
distro.

> [!WARNING] Perform `dnf update` immediately

### [Repositories](https://wiki.almalinux.org/repos/)

These may not really be necessary to set up, but you should absolutely review
them and decide for yourself.

- [AlmaLinux](https://wiki.almalinux.org/repos/AlmaLinux.html)
- [CentOS SIGs](https://wiki.almalinux.org/repos/CentOS.html)
- [Extra](https://wiki.almalinux.org/repos/Extras.html)
    - EPEL and CRB
        - `dnf install epel-release`
        - `dnf config-manager --set-enabled crb`
    - ELRepo
        - `dnf install elrepo-release`
    - [RPM Fusion](https://wiki.almalinux.org/documentation/epel-and-rpmfusion.html)

### Disks

#### Partitions

Repeat the following steps for all disks that you want to join together into
one single logical volume.

```bash
# Find /dev/sdX paths for disks
# WARNING: Make sure you confirm the disk is correct
lsblk -f
# Clear the partition table
dd if=/dev/zero of=/dev/sdX bs=512 count=1 conv=notrunc
# Create LVM partition
parted --fix --align optimal --script /dev/sdX \
    mklabel gpt \
    mkpart primary ext4 1MiB -2048s \
    set 1 lvm on
```

#### LVM

```bash
# Create physical volume
pvcreate /dev/sdX1
# Create volume group for disks
vgcreate library /dev/sdX1
# Add more disks to volume group
vgextend library /dev/sdY1
# Create logical volume across all disks in volume group
lvcreate -l100%FREE -n books library
# Add filesystem to logical volume
mke2fs -t ext4 /dev/library/books
# Check it
e2fsck -f /dev/library/books
```

#### /etc/systemd/system/volumes-books.mount

```ini
[Mount]
What=/dev/library/books
Where=/volumes/books
Type=ext4

[Install]
WantedBy=default.target
```

```bash
mkdir -p /volumes/books
chown -R $ctuser:$ctuser /volumes
```

### SSH

SSH is optional, but highly encouraged. Cockpit gives you a terminal too, but
that's nowhere near as good as what you can do with a real terminal emulator
and ssh clients.

```bash
dnf install openssh-server

## Generate strong key on your laptop or workstation/desktop
ssh-keygen -t ed25519 -a 32 -f ~/.ssh/$localhost-to-$remotehost

## Copy key to AlmaLinux
ssh-copy-id -i ~/.ssh/$localhost-to-$remotehost $user@$remotehost
```

#### Override `sshd` config

We don't want to allow anyone to login as root remotely ever. You must be a
`sudoer` with public key auth to elevate to root.

```bash
printf '%s\n' 'PermitRootLogin no' > /etc/ssh/sshd_config.d/01-root.conf
printf '%s\n' \
    'PubkeyAuthentication yes' \
    'PasswordAuthentication no' > /etc/ssh/sshd_config.d/01-pubkey.conf
```

## Cockpit -> https://ip-addr:9090

> [!WARNING] Disable the firewall if you are lazy
> Exposing ports for other services can be exhausting and I have not learned
> how to do this for containers properly. Each container may need a new rule
> for something, not sure.
> ```bash
> systemctl disable --now firewalld
> ```

> [!TODO] Should be able to set up good firewall with only 80/443 open.

Enable the socket-activated cockpit service and allow it through the firewall.

```bash
systemctl enable --now cockpit.socket

# FIXME: Unnecessary? Default works?
firewall-cmd --permanent --zone=public --add-service=cockpit
firewall-cmd --reload
```

### Add SSH keys

> [!TIP] Skip if you copied your keys with `ssh-copy-id` above.

`Accounts` -> `Your account` -> `Authorized public SSH keys` -> `Add Key`

### Install SELinux troubleshoot tool

This is a component for Cockpit.

```bash
dnf install setroubleshoot-server
```

## Podman

Podman is a daemonless container hypervisor. This document prepares a fully
rootless environment for our containers to run in.

### Install

```bash
dnf install podman
systemctl enable --now podman
```

> [!NOTE] Read the docs.
> `man podman-systemd.unit`

### slirp4netns

> [!TODO]
> This may not be necessary but my system is currently using it.

```bash
dnf install slirp4netns
```

### Install DNS server for `podman`

> [!TODO]
> Not sure how to resolve these correctly yet but the journal logs it
> so it's running for something.

```bash
dnf install aardvark-dns
```

### Enable unprivileged port binding

> [!NOTE] This is only necessary if you are setting up the reverse proxy.

```bash
printf '%s\n' 'net.ipv4.ip_unprivileged_port_start=80' > /etc/sysctl.d/99-unprivileged-port-binding.conf
sysctl 'net.ipv4.ip_unprivileged_port_start=80'
```

### Prepare container user

This user will be the owner of all containers with no login shell or root
privileges.

```bash
# Prepare a group id outside of the normal range
groupadd --gid 2000 $ctuser
# Create user with restrictions
# We need the $HOME to live in
useradd --create-home \
    --shell /usr/bin/false \
    --password $ctuser_pw \
    --no-user-group \
    --gid $ctuser \
    --groups systemd-journal \
    --uid 2000 \
    $ctuser
# Lock user from password login
usermod --lock $ctuser
# Add container sub-ids
usermod --add-subuids 200000-299999 --add-subgids 200000-299999 $ctuser
# Start $ctuser session at boot without login
loginctl enable-linger $ctuser
```

> [!TIP] Optionally setup ssh keys to directly login to $ctuser.

> [!NOTE] The login shell doesn't exist.
> Launch `bash -l` manually to get a shell or else your `ssh` will exit with a
> status of 1.

### Setup $ctuser env

```bash
# Switch to user (`-i` doesn't work without a login shell)
sudo -u $ctuser bash -l
# Create dirs
mkdir -p ~/.config/{containers/systemd,environment.d} ~/containers/storage
# Prepare `systemd --user` env
echo 'XDG_RUNTIME_DIR=/run/user/2000' >> ~/.config/environment.d/10-xdg.conf
# Enable container auto-update
podman system migrate
# WARNING: Set strict versions for all containers or risk catastrophe
systemctl --user enable --now podman-auto-update
exit
```

> [!WARNING] I disabled SELinux to not deal with this for every container.
> /etc/selinux/config -> `SELINUX=disabled`

> [!TODO] Set up the correct policies permanently instead of disabling SELinux

Temporarily set SELinux policy to allow containers to use devices.

```bash
setsebool -P container_use_devices 1
```

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
- [ ] [Kibitzr](https://kibitzr.github.io/)
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

