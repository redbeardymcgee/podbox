# Ubuntu Server

Setting up rootless podman on a fresh Ubuntu 24.10 server.

> [!WARNING]
> Perform `sudo apt update && sudo apt upgrade` immediately. Reboot system.

## SSH

SSH is optional, but highly encouraged. OpenSSH is installed by default and sshd
is running by default.

```bash
## Generate strong key on your laptop or workstation/desktop
## If you already have keys DO NOT overwrite your previous keys

ssh-keygen -t ed25519 -a 32 -f ~/.ssh/$localhost-to-$remotehost

## Optionally set a passphrase

## Copy key to Ubuntu
ssh-copy-id username@remote_host
```

## Override `sshd` config

We don't want to allow anyone to login as root remotely ever. You must be a
`sudoer` with public key auth to elevate to root.

SSH into your server and run

```bash
printf '%s\n' 'PermitRootLogin no' | sudo tee /etc/ssh/sshd_config.d/01-root.conf
printf '%s\n' \
    'PubkeyAuthentication yes' \
    'PasswordAuthentication no' | sudo tee /etc/ssh/sshd_config.d/01-pubkey.conf
```

Save file and then run `systemctl restart ssh` Before closing your session, open
a new terminal and test SSH is functioning correctly.

## Podman

Podman is a daemonless container hypervisor. This document prepares a fully
rootless environment for our containers to run in.

## Install

```bash
sudo apt install podman systemd-container

## Make sure podman is running
systemctl enable --now podman
```

> [!NOTE]
> Read the docs. `man podman-systemd.unit`

## Prepare host networking stack

## Pasta or slirp4netns

> [!NOTE]
> As of Podman 5.0 Pasta is the default rootless networking tool.
>
> Podman 5.0 is available in standard Ubuntu repo since 24.10.
>
> Both are installed with podman see
> [rootless networking for configuration](https://github.com/containers/podman/blob/main/docs/tutorials/rootless_tutorial.md#networking-configuration)

## Allow rootless binding port 80+

### Modify range of unprivileged ports

> [!NOTE]
> This is only necessary if you are setting up the reverse proxy (or any service
> on ports <1024).

```bash
printf '%s\n' 'net.ipv4.ip_unprivileged_port_start=80' | sudo tee /etc/sysctl.d/99-unprivileged-port-binding.conf
sysctl -w 'net.ipv4.ip_unprivileged_port_start=80'
```

## Prepare container user

This user will be the owner of all containers with no login shell or root
privileges.

Container user should have range of uid/gid automatically generated. See
[subuid and subgid tutorial](https://github.com/containers/podman/blob/main/docs/tutorials/rootless_tutorial.md#etcsubuid-and-etcsubgid-configuration)
to verify range or create if it does not exist.

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
# Start $ctuser session at boot without login
loginctl enable-linger $ctuser
```

> [!NOTE]
> Consider removing bash history entry that contains the password entered above

## Setup $ctuser env

> [!NOTE]
> Use machinectl instead of sudo or su to get a shell that is fully isolated
> from the original session. See the developers comments on the problem
> [with su](https://github.com/systemd/systemd/issues/825#issuecomment-127917622)
> as well as the purpose of
> [machinectl shell](https://github.com/systemd/systemd/pull/1022#issuecomment-136133244)

```bash
# Switch to $ctuser
# Note do not remove the trailing @
machinectl shell $ctuser@ /bin/bash
# Create dirs
mkdir -p ~/.config/{containers/systemd,environment.d}
# Prepare `systemd --user` env
echo 'XDG_RUNTIME_DIR=/run/user/2000' >> ~/.config/environment.d/10-xdg.conf
# Enable container auto-update
podman system migrate
# WARNING: Set strict versions for all containers or risk catastrophe
systemctl --user enable --now podman-auto-update
exit
```

## Podman fails autostart

In Podman < 5.3 containers may fail to autostart because user level units cannot depend on system level units (in this case `network-online.target`)

Podman >= 5.3 should ship with a workaround user unit that can be used `podman-user-wait-network-online.service`, use that instead of the fix below.  

See [this github issue](https://github.com/containers/podman/issues/22197) for workarounds, the workaround below is what worked for me. The google.com ping can be replaced with your preferred (reachable) ip/host

To fix this, create the following

```bash
# ~/.config/systemd/user/network-online.service
[Unit]
Description=User-level proxy to system-level network-online.target

[Service]
Type=oneshot
ExecStart=sh -c 'until ping -c 1 google.com; do sleep 5; done'

[Install]
WantedBy=default.target
```
```bash
# ~/.config/systemd/user/network-online.target
[Unit]
Description=User-level network-online.target
Requires=network-online.service
Wants=network-online.service
After=network-online.service
```
Then enable the service `systemctl --user enable network-online.service`

In quadlets add the following:

```bash
[Unit]
After=network-online.target
```
