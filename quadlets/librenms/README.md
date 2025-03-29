# LibreNMS

## Create DB password secret

```bash
printf 'supersecretpassword' | podman secret create librenms-db-pw -
```

## Known Issues

- Dependencies are not respected at all
    - Launch each container service manually for now
