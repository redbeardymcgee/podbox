# Ubuntu Server 

Setting up rootless podman on a fresh ubuntu 24.10 server.

> [!WARNING]
> Perform `sudo apt update && sudo apt upgrade` immediately. Perform reboot if necessary

## SSH

SSH is optional, but highly encouraged. OpenSSH is installed by default and sshd is running by default.

```bash
## Generate strong key on your laptop or workstation/desktop
## If you already have keys DO NOT overwrite your previous keys

ssh-keygen

## Optionally set a passphrase

## Copy key to Ubuntu
ssh-copy-id username@remote_host
```

## Override `sshd` config

We don't want to allow anyone to login as root remotely ever. You must be a
`sudoer` with public key auth to elevate to root.

SSH into your server and run `sudoedit /etc/ssh/sshd_config` See [stackoverflow question](https://superuser.com/questions/785187/sudoedit-why-use-it-over-sudo-vi) for reasons to use sudoedit over sudo.

```bash
## Uncomment PasswordAuthentication and set value to no
PasswordAuthentication no

## Disable root login
PermitRootLogin no

## Optionally disable X11 forwarding
X11Forwarding no
```
Save file and then run `systemctl restart ssh` Before closing your session, open a new terminal and test SSH is functioning correctly.

## Podman

Podman is a daemonless container hypervisor. This document prepares a fully
rootless environment for our containers to run in.

## Install

```bash
dnf install podman
systemctl enable --now podman
```

> [!NOTE]
> Read the docs.
> `man podman-systemd.unit`

## Prepare host networking stack

## slirp4netns

> [!NOTE]
> This may not be necessary but my system is currently using it.

```bash
dnf install slirp4netns
```

## Install DNS server for `podman`

> [!NOTE]
> Not sure how to resolve these correctly yet but the journal logs it
> so it's running for something.

```bash
dnf install aardvark-dns
```

## Allow rootless binding port 80+

> [!NOTE]
> This is only necessary if you are setting up the reverse proxy.

```bash
printf '%s\n' 'net.ipv4.ip_unprivileged_port_start=80' > /etc/sysctl.d/99-unprivileged-port-binding.conf
sysctl 'net.ipv4.ip_unprivileged_port_start=80'
```

## Allow containers to route within multiple networks

```bash
printf '%s\n' 'net.ipv4.conf.all.rp_filter=2' > /etc/sysctl.d/99-reverse-path-loose.conf
sysctl -w net.ipv4.conf.all.rp_filter=2
```

## Prepare container user

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

> [!TIP]
> Optionally setup ssh keys to directly login to $ctuser.

> [!NOTE]
> The login shell doesn't exist. Launch `bash -l` manually to get a shell or
> else your `ssh` will exit with a status of 1.

## Setup $ctuser env

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

> [!WARNING]
> I disabled SELinux to not deal with this for every container.
> /etc/selinux/config -> `SELINUX=disabled`

> [!NOTE]
> Set up the correct policies permanently instead of disabling SELinux

Temporarily set SELinux policy to allow containers to use devices.

```bash
setsebool -P container_use_devices 1
```
