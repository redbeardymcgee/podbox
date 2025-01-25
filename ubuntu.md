# Ubuntu Server 

Setting up rootless podman on a fresh ubuntu 24.10 server.

> [!WARNING]
> Perform `sudo apt update && sudo apt upgrade` immediately. Reboot system.

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

SSH into your server and run `sudoedit /etc/ssh/sshd_config` 

See [stackoverflow question](https://superuser.com/questions/785187/sudoedit-why-use-it-over-sudo-vi) for reasons to use sudoedit over sudo.

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
sudo apt install podman

## Make sure podman is running
systemctl enable --now podman
```

> [!NOTE]
> Read the docs.
> `man podman-systemd.unit`

## Prepare host networking stack

## Pasta or slirp4netns

> [!NOTE]
> As of Podman 5.0 Pasta is the default rootless networking tool.
> 
> Podman 5.0 is available in standard Ubuntu repo since 24.10.
>
> Both are installed with podman see [rootless networking for configuration](https://github.com/containers/podman/blob/main/docs/tutorials/rootless_tutorial.md#networking-configuration)

## Allow rootless binding port 80+

### Option 1: Modify range of unpriveleged ports

> [!NOTE]
> This is only necessary if you are setting up the reverse proxy (or any service on ports <1024).

`sudoedit /etc/sysctl.conf`
```bash
## Add the following line and save
net.ipv4.ip_unprivileged_port_start=80
```

### Option 2: Redirect using firewalls
See [jdboyd blog post for PARTIAL examples using UFW, iptables, and nftables](https://blog.jdboyd.net/2024/05/exposing-privileged-ports-with-podman/)

>[!WARNING]
> IF UTILIZING THIS METHOD
>
> CREATE RULES TO ALLOW SSH BEFORE ENABLING THE FIREWALL

## Prepare container user

This user will be the owner of all containers with no login shell or root
privileges. 

Note $ctuser is a placeholder, replace with your username

```bash
# Prepare a group id outside of the normal range
sudo groupadd --gid 2000 $ctuser
# Create user with restrictions
# We need the $HOME to live in
sudo useradd --create-home \
    --shell /usr/bin/false \
    --password $ctuser_pw \
    --no-user-group \
    --gid $ctuser \
    --groups systemd-journal \
    --uid 2000 \
    $ctuser
# Lock user from password login
sudo usermod --lock $ctuser
# Add container sub-ids
sudo usermod --add-subuids 200000-299999 --add-subgids 200000-299999 $ctuser
# Start $ctuser session at boot without login
loginctl enable-linger $ctuser
```

## Setup $ctuser env

>[!NOTE]
> See the following for reasons to use machinectl instead of su
> [RedHat blog post](https://www.redhat.com/en/blog/sudo-rootless-podman)
>
> [reddit post](https://old.reddit.com/r/linuxadmin/comments/rxrczr/in_interesting_tidbit_i_just_learned_about_the/)

Install systemd-container
`sudo apt install systemd-container`

```bash
# Switch to $ctuser
# Note do not remove the trailing @
machinectl shell $ctuser@ /bin/bash
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
