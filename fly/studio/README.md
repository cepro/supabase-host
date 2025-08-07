# Supabase Studio on Fly

```sh
fly launch --no-deploy --no-public-ips --org <myorg> --name supabase-studio-<myorg>  --region lhr --copy-config --config fly-studio-<myorg>.toml

# set secrets
cp secrets.example.sh secrets.sh
./secrets.sh

fly --config fly-studio-<myorg>.toml deploy
fly --config fly-studio-<myorg>.toml scale count 1
fly --config fly-studio-<myorg>.toml ips allocate-v6 --private
```
