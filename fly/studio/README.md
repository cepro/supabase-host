# Supabase Studio on Fly

```sh
fly launch --no-deploy --org <myorg> --name supabase-studio-<myorg>  --region lhr --copy-config --config fly-studio.toml

# set secrets
cp secrets.example.sh secrets.sh
./secrets.sh

fly --config fly-studio.toml deploy
fly --config fly-studio.toml scale count 1
```
