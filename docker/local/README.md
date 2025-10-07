# Run stack locally

## First time run

```sh
# First time only
supabase-host/docker/local> docker compose up db -d

supabase-host/sqitch> SQITCH_USER_CONFIG=sqitch_secrets.local.conf sqitch deploy --target timescale-local

flows-db/sqitch> SQITCH_USER_CONFIG=sqitch_secrets.local.conf sqitch deploy --target timescale-local
flows-db> bin/ts-seed

# Start all containers - this runs migrations inside containers like auth
docker/local> docker compose up -d
    
# Run myenergy after stack started because it depends on some migrations in the
# auth container that add columns to auth.users
myenergy-db/sqitch> SQITCH_USER_CONFIG=sqitch_secrets.local.conf sqitch deploy --target timescale-local
myenergy-db> bin/seed
```

# Teardown and remove data
```sh
docker/local> docker compose rm -s
docker/local> docker volume rm timescaledb_data
```
