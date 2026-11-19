#!/bin/sh
# Entrypoint for Kong 3.x: substitute environment variables into the declarative
# config, then start Kong.
#
# Adapted from supabase/supabase docker/volumes/api/kong-entrypoint.sh (self-hosted
# v0.8.4). Uses awk instead of the old `eval echo` trick, which stripped double
# quotes and so broke YAML values like "Header: value". Only variables that are
# set in the environment are substituted; anything else is left as-is.
awk '{
  result = ""
  rest = $0
  while (match(rest, /\$[A-Za-z_][A-Za-z_0-9]*/)) {
    varname = substr(rest, RSTART + 1, RLENGTH - 1)
    if (varname in ENVIRON) {
      result = result substr(rest, 1, RSTART - 1) ENVIRON[varname]
    } else {
      result = result substr(rest, 1, RSTART + RLENGTH - 1)
    }
    rest = substr(rest, RSTART + RLENGTH)
  }
  print result rest
}' /home/kong/temp.yml > "$KONG_DECLARATIVE_CONFIG"

exec /entrypoint.sh kong docker-start
