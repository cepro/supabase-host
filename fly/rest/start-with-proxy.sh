#!/bin/bash
#
# This script exists to workaround an issue with ipv6 binding in postgREST.
# ipv4 binding doesn't work with fly internal networking and postgREST as 
# far as I could see.
#
# Related issues:
#   https://github.com/fpco/streaming-commons/issues/78
#   https://github.com/yesodweb/wai/issues/976
#   https://github.com/PostgREST/postgrest/issues/3202
#   https://github.com/PostgREST/postgrest/issues/3203
#

echo "Starting PostgREST IPv6 proxy setup..."

# Start PostgREST on IPv4 localhost:3001 in background
echo "Starting PostgREST on 127.0.0.1:3001..."
PGRST_SERVER_HOST=127.0.0.1 PGRST_SERVER_PORT=3001 postgrest &

# Store PostgREST PID
POSTGREST_PID=$!

# Wait for PostgREST to start
echo "Waiting for PostgREST to start..."
sleep 3

# Check if PostgREST is running
if ! kill -0 $POSTGREST_PID 2>/dev/null; then
    echo "ERROR: PostgREST failed to start"
    exit 1
fi

# Start socat IPv6 proxy: IPv6:3000 -> IPv4:3001
echo "Starting socat IPv6 proxy on [::]:3000 -> 127.0.0.1:3001..."
exec socat TCP6-LISTEN:3000,fork,reuseaddr,ipv6only=0 TCP:127.0.0.1:3001
