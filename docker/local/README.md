# Run stack locally

## First time run

```sh
# First time only
supabase-host/docker/local> docker compose up db -d

supabase-host/sqitch> SQITCH_USER_CONFIG=sqitch_secrets.local.conf sqitch deploy --target timescale-local

flows-db/sqitch> SQITCH_USER_CONFIG=sqitch_secrets.local.conf sqitch deploy --target timescale-local
flows-db> bin/ts-seed

myenergy-db/sqitch> SQITCH_USER_CONFIG=sqitch_secrets.local.conf sqitch deploy --target timescale-local
myenergy-db> bin/supa-seed

# Everytime
docker/local> docker compose up -d
```
