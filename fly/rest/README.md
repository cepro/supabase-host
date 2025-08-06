# Supabase Rest on Fly

```sh
fly launch --no-deploy --no-public-ips --org <myorg> --name supabase-rest-<myorg>  --region lhr --copy-config --config fly-rest.toml

# set secrets
cp secrets.example.sh secrets.sh
./secrets.sh

fly --config fly-rest.toml deploy
fly --config fly-rest.toml scale count 1
```


