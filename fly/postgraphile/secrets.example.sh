fly --config fly-postgraphile-<myorg>.toml secrets set DATABASE_URL="postgres://postgraphile:postgraphile@172.17.0.1:15432/tsdb"
fly --config fly-postgraphile-<myorg>.toml secrets set JWT_SECRET=""
