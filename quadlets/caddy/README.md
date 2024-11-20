# podman 5.2.5

```bash
dnf -y install btrfs-progs-devel passt
curl -fsSL \
    -o podman-5.2.5.tar.gz \
    https://github.com/containers/podman/archive/refs/tags/v5.2.5.tar.gz
tar xzf podman-5.2.5.tar.gz
cd podman-5.2.5
make BUILDTAGS="selinux seccomp" PREFIX=/usr
```
