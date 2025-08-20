#!/bin/sh
set -e

# Start PostGraphile with expanded environment variables
exec /postgraphile/cli.js \
  --connection "$DATABASE_URL" \
  --jwt-secret "$JWT_SECRET" \
  --schema myenergy \
  --enhance-graphiql \
  --jwt-verify-audience '' \
  --jwt-role role \
  --jwt-token-identifier myenergy.jwt_claims