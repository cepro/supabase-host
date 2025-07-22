# Supabase Kong on Fly

```sh
fly launch --no-deploy --org <myorg> --name supabase-auth-<myorg>  --region lhr --copy-config --config fly-auth.toml

# set secrets
cp secrets.example.sh secrets.sh
./secrets.sh

fly --config fly-auth.toml deploy
fly --config fly-auth.toml scale count 1
```


