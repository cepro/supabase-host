# supabase-host

Holds deployment configuration and scripts to self-host Supabase 

## Migrations

```sh
# setup secrets - edit this file with new passwords
sqitch> cp sqitch_secrets.conf.example sqitch_secrets.conf

# run the migrations - add your timescale-<org> connection details to sqitch.conf
SQITCH_USER_CONFIG=sqitch_secrets.conf sqitch deploy --target timescale-<org>
```
