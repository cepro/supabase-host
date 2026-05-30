#!/bin/bash
# Set secrets for supabase-home-<myorg>
# Copy this file to secrets-<myorg>.sh and fill in actual values from simt-supabase/local-dev.env

fly --config fly-home-<myorg>.toml secrets set \
  SUPABASE_SERVICE_KEY="" \
  FLOWS_ROLE_JWT="" \
  FLUX_JWT=""
