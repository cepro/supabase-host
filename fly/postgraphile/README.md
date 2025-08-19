# PostGraphile on Fly

```sh
fly launch --no-deploy --no-public-ips --org <myorg> --name supabase-postgraphile-<myorg>  --region lhr --copy-config --config fly-postgraphile-<myorg>.toml

# set secrets
cp secrets.example.sh secrets.sh
./secrets.sh

fly --config fly-postgraphile-<myorg>.toml deploy
fly --config fly-postgraphile-<myorg>.toml scale count 1
fly --config fly-postgraphile-<myorg>.toml ips allocate-v6 --private
```

