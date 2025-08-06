# Run stack locally

## First time run

```sh
# First time only
docker/local> docker compose up db -d
sqitch> SQITCH_USER_CONFIG=sqitch_secrets.local.conf sqitch deploy --target timescale-local

# Everytime
docker/local> docker compose up -d
```
