# AlmaLinux

My proof of concept server running this container stack is built on AlmaLinux
9.4.

> [!WARNING]
> Perform `dnf update` immediately

## [Repositories](https://wiki.almalinux.org/repos/)

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

## Disks

### Partitions

Repeat the following steps for all disks that you want to join together into
one single logical volume.

```bash
# Find /dev/sdX paths for disks
# WARNING: Make sure you confirm the disk is correct
lsblk -f
# Clear the partition table
dd if=/dev/zero of=/dev/sdX bs=512 count=1 conv=notrunc
dd if=/dev/zero of=/dev/sdY bs=512 count=1 conv=notrunc
```

### LVM

```bash
# Create physical volume
pvcreate /dev/sdX
# Create volume group for disks
vgcreate library /dev/sdX
# Add more disks to volume group
vgextend library /dev/sdY
# Create logical volume across all disks in volume group
lvcreate -l100%FREE -n books library
# Add filesystem to logical volume
mke2fs -t ext4 /dev/library/books
# Check it
e2fsck -f /dev/library/books
```

### /etc/systemd/system/volumes-books.mount

```ini
[Mount]
What=/dev/library/books
Where=/volumes/books
Type=ext4

[Install]
WantedBy=default.target
```

> [!NOTE]
> We could use a different filesystem that allows mount options to set the
> permissions

```bash
chown -R $ctuser:$ctuser /volumes
```

## SSH

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

## Override `sshd` config

We don't want to allow anyone to login as root remotely ever. You must be a
`sudoer` with public key auth to elevate to root.

```bash
printf '%s\n' 'PermitRootLogin no' > /etc/ssh/sshd_config.d/01-root.conf
printf '%s\n' \
    'PubkeyAuthentication yes' \
    'PasswordAuthentication no' > /etc/ssh/sshd_config.d/01-pubkey.conf
```

## Cockpit -> https://ip-addr:9090

> [!WARNING]
> I run behind an existing firewall, not in a VPS or cloud provider.
> ```bash
> systemctl disable --now firewalld
> ```

> [!NOTE]
> Should be able to set up good firewall with only 22/80/443 open.

Enable the socket-activated cockpit service and allow it through the firewall.

```bash
systemctl enable --now cockpit.socket

# FIXME: Unnecessary? Default works?
firewall-cmd --permanent --zone=public --add-service=cockpit
firewall-cmd --reload
```

## Add SSH keys

> [!TIP]
> Skip if you copied your keys with `ssh-copy-id` above.

`Accounts` -> `Your account` -> `Authorized public SSH keys` -> `Add Key`

## Install SELinux troubleshoot tool

This is a component for Cockpit.

```bash
dnf install setroubleshoot-server
```

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

### slirp4netns

> [!NOTE]
> This may not be necessary but my system is currently using it.

```bash
dnf install slirp4netns
```

### Install DNS server for `podman`

> [!NOTE]
> Not sure how to resolve these correctly yet but the journal logs it
> so it's running for something.

```bash
dnf install aardvark-dns
```

### Allow rootless binding port 80+

> [!NOTE]
> This is only necessary if you are setting up the reverse proxy.

```bash
printf '%s\n' 'net.ipv4.ip_unprivileged_port_start=80' > /etc/sysctl.d/99-unprivileged-port-binding.conf
sysctl -w net.ipv4.ip_unprivileged_port_start=80
```

### Allow containers to route within multiple networks

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

### Setup $ctuser env

> [!NOTE]
> The login shell doesn't exist. Launch `bash -l` manually to get a shell or
> else your `ssh` will exit with a status of 1.

```bash
# Switch to user (`-i` doesn't work without a login shell)
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

> [!WARNING]
> I disabled SELinux to not deal with this for every container.
> /etc/selinux/config -> `SELINUX=disabled`

> [!TIP]
> Set up the correct policies permanently instead of disabling SELinux

Temporarily set SELinux policy to allow containers to use devices.

```bash
setsebool -P container_use_devices 1
```

