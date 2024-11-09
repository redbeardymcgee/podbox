# MAM Stack

> [!TIP] Get protonvpn user/pass
> [OpenVpnIKEv2](https://account.proton.me/u/0/vpn/OpenVpnIKEv2)

## /etc/systemd/system/volumes-books.mount

```ini
[Unit]
Description=Mount LVM for storage

[Mount]
What=/dev/library/books
Where=/volumes/books
Type=ext4

[Install]
WantedBy=default.target
```

## /volumes/books/gluetun/auth/config.toml

This allows us to query the `gluetun` API for the forwarded port without
needing an API user and password.

> [!WARNING] Do not expose the API to the internet.

```toml
[[roles]]
name = "qbittorrent"
routes = ["GET /v1/openvpn/portforwarded"]
auth = "none"
```
