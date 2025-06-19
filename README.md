# supabase-host
Holds deployment configuration and scripts to self-host Supabase 


## Work-in-progress

The aim is to self-host Supabase on Upcloud, this allows us to run the full Timescale extension.

Steps:

MW 18/06/2025
1. I took copies of the Supabase example docker-compose files into this repo as a starting point: https://supabase.com/docs/guides/self-hosting/docker
1. I built the `cepro/postgres` docker image (tagged as `postgres-cep`) and changed the docker-compose to use that image. Make sure you use the `with-timescale` branch of `cepro/postgres`!. Eventually we want to push this to Docker Hub image repository.
1. Ran up the docker-compose, connected to Supabase Studio, and checked the postgres version (17.4)
1. To connect to the postgres server, you need to use the username `postgres.your-tenant-id` because there is a pooler, and password is `your-super-secret-and-long-postgres-password`
1. I edited the `cepro/postgres` image to allow us to enable the timescaledb extension (it needs to be listed in `shared_preload_libraries`).
1. I edited my DB migrations to include `CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE;` before using timescale functionality.
1. I edited my DB migrations to use Postgres variables rather than SQL templating - this would require the secrets to be written into sqitch.conf - which might be reasonable and simpler then the templating method
1. I got stuck with JWT access to the database - I keep getting "Invalid authentication credentials" messages which I'm guessing is coming from Kong

MW 19/06/2025:
1. The JWT issues have resolved with no particular action - I suspect I had the wrong combination of JWT tokens / database authentication etc. In short - it works as it should without any changes! I just find it a bit finickety to get running.
1. I couldn't get the timescaledb toolkit running - I get an error relating to a missing nix file or something... I'll wait on this as Chris has had it running successfully.
1. Moved the postgres Docker image into the github docker registry


Todo:
- Get JWT based auth working
- Add timescale toolkit (to postgres docker build?)
- Consolidate the deployment system (currently Terraform running scripts)
- Spin-up a system on Upcloud:
    - Secrets would need setting

