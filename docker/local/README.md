# Run stack locally

## First time run

```sh
# First time only
supabase-host/docker/local> docker compose up db -d
supabase-host/sqitch> SQITCH_USER_CONFIG=sqitch_secrets.local.conf sqitch deploy --target timescale-local
flows-db> SQITCH_USER_CONFIG=sqitch_secrets.local.conf sqitch deploy --target timescale-local
myenergy-db> SQITCH_USER_CONFIG=sqitch_secrets.local.conf sqitch deploy --target timescale-local

# Everytime
docker/local> docker compose up -d
```
