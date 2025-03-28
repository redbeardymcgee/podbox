## Create DB password secret

```bash
printf 'supersecretpassword' | podman secret create librenms-db-pw -
```
