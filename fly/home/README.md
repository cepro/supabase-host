# Simtricity Communities Home on Fly

Developer portal and API documentation for Simtricity Communities platform.

## Deployment

```sh
# Launch new app (first time only)
fly launch --no-deploy --org <myorg> --name supabase-home-<myorg> --region lhr --copy-config --config fly-home-<myorg>.toml

# Set secrets
cp secrets.example.sh secrets-<myorg>.sh
# Edit secrets-<myorg>.sh with actual JWT values from simt-supabase/local-dev.env
./secrets-<myorg>.sh

# Deploy
fly --config fly-home-<myorg>.toml deploy

# Scale (auto-start on demand)
fly --config fly-home-<myorg>.toml scale count 1

# Allocate private IPv6 (required for Flycast networking / Kong access)
fly --config fly-home-<myorg>.toml ips allocate-v6 --private
```

## Architecture

This app is accessed **only via Kong Gateway** at:
- `/` - Public homepage (service catalog)
- `/api/docs/*` - API documentation (basic auth protected)

No public internet access - all requests go through Kong on port 8000 internally via Flycast private network.

## Source Code

Application code is in `/Users/damonrand/code/supabase/simt-supabase-home/`

See that directory's README.md for local development instructions.
