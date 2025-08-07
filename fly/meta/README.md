# Supabase Meta on Fly

```sh
fly launch --no-deploy  --no-public-ips --org <myorg> --name supabase-meta-<myorg>  --region lhr --copy-config --config fly-meta-<myorg>.toml

fly --config fly-meta-<myorg>.toml deploy
fly --config fly-meta-<myorg>.toml scale count 1
```


