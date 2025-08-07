# Supabase Auth on Fly

```sh
fly launch --no-deploy --no-public-ips --org <myorg> --name supabase-auth-<myorg>  --region lhr --copy-config --config fly-auth-<myorg>.toml

# set secrets
cp secrets.example.sh secrets.sh
./secrets.sh

fly --config fly-auth-<myorg>.toml deploy
fly --config fly-auth-<myorg>.toml scale count 1
```


