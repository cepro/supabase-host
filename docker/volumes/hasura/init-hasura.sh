#!/bin/bash

# Start Hasura in the background
echo "Starting Hasura..."
graphql-engine serve &
HASURA_PID=$!

# Wait for Hasura to be ready
echo "Waiting for Hasura to start..."
while ! curl -s http://localhost:8080/healthz > /dev/null; do
    sleep 2
done

echo "Hasura is ready, applying metadata..."

# Apply metadata if it exists
if [ -f /hasura-metadata/metadata.json ]; then
    echo "Found metadata.json, applying..."
    curl -X POST http://localhost:8080/v1/metadata \
        -H "X-Hasura-Admin-Secret: ${HASURA_GRAPHQL_ADMIN_SECRET}" \
        -H "Content-Type: application/json" \
        -d "{\"type\":\"replace_metadata\",\"args\":$(cat /hasura-metadata/metadata.json)}"
    echo "Metadata applied successfully"
else
    echo "No metadata.json found, skipping metadata application"
fi

# Wait for Hasura process to finish
wait $HASURA_PID