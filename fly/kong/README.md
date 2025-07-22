# Supabase Kong on Fly

```sh
fly launch --no-deploy --org <myorg> --name supabase-kong-<myorg> --region lhr --copy-config --config fly-kong.toml

# set secrets
cp secrets.example.sh secrets.sh
./secrets.sh

fly --config fly-kong.toml deploy
fly --config fly-kong.toml scale count 1
```


