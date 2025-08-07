# Supabase Kong on Fly

```sh
fly launch --no-deploy --org <myorg> --name supabase-kong-<myorg> --region lhr --copy-config --config fly-kong-<myorg>.toml

# set secrets
cp secrets.example.sh secrets-<myorg>.sh
./secrets-<myorg>.sh

fly --config fly-kong-<myorg>.toml deploy
fly --config fly-kong-<myorg>.toml scale count 1
```


