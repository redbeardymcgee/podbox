# calibre-web

## Known issues

### The starter metadata.db is required even if you do not use `calibre`

> [!WARNING]
> This should be run as your `$ctuser` or it will have the wrong owner and
> permissions

```bash
curl -fLSs -o /home/$ctuser/.local/share/containers/storage/volumes/calibre-web-database/metadata.db https://github.com/janeczku/calibre-web/raw/master/library/metadata.db
```
