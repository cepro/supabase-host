# supabase-host
Holds deployment configuration and scripts to self-host Supabase 


## Work-in-progress Steps

The aim is to self-host Supabase on Upcloud, this allows us to run the full Timescale extension.

Steps:

MW 18/06/2025
1. Copied the Supabase docker-compose examples into this repo: https://supabase.com/docs/guides/self-hosting/docker
2. Built the `with-timescale` branch of the Cepro postgres docker image and tagged as `postgres-cep`: https://github.com/cepro/postgres/tree/with-timescale
3. Replaced the `db` services image our custom image `postgres-cep`
4. Ran up the docker-compose, connected to Supabase Studio, and checked the postgres version (17.4)
5. To connect to the postgres server, you need to use the username `postgres.your-tenant-id` because there is a pooler, and password is `your-super-secret-and-long-postgres-password`
6. I edited the postgres image to allow us to enable the timescaledb extension (it needs to be listed in shared_preload_libraries).
7. I edited my DB migrations to include `CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE;` before using timescale functionality.

