#!/bin/bash

# Fetch Plex version and update Nomad variable
set -e

echo "Fetching Plex version from API..."
PLEX_VERSION=$(curl -s "https://plex.tv/api/downloads/5.json?channel=plexpass" | jq -r '.computer.Linux.version')

if [ "$PLEX_VERSION" = "null" ] || [ -z "$PLEX_VERSION" ]; then
    echo "Error: Failed to extract Plex version from API response"
    exit 1
fi

echo "Extracted Plex version: $PLEX_VERSION"

echo "Writing version to Nomad variable..."
nomad var put -force nomad/jobs/plex claim_token="claim-XXXXX" version="$PLEX_VERSION"

echo "Successfully updated Nomad variable nomad/jobs/plex with version: $PLEX_VERSION"
