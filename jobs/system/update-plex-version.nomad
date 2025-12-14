# This job periodically fetches the latest Plex version and updates the Nomad variable.
job "update-plex-version" {
  datacenters = ["dc1"]
  type        = "batch"

  # Run daily at 3am
  periodic {
    cron             = "0 3 * * *"
    prohibit_overlap = true
  }

  group "update" {
    count = 1

    task "fetch-version" {
      driver = "podman"

      config {
        image = "docker.io/hashicorp/nomad:latest"
        args  = ["/bin/sh", "-c", "/local/update-plex-version.sh"]
      }

      # Embedded script that preserves the existing claim token
      template {
        data = <<EOF
#!/bin/sh
set -e

echo "Fetching Plex version from API..."
PLEX_VERSION=$(wget -qO- "https://plex.tv/api/downloads/5.json?channel=plexpass" | \
  sed -n 's/.*"version":"\([^"]*\)".*/\1/p' | head -1)

if [ -z "$PLEX_VERSION" ]; then
    echo "Error: Failed to extract Plex version from API response"
    exit 1
fi

echo "Extracted Plex version: $PLEX_VERSION"

# Get existing claim token from Nomad variable
EXISTING_TOKEN={{- with nomadVar "nomad/jobs/plex" -}}{{ .claim_token }}{{- end }}

if [ -z "$EXISTING_TOKEN" ]; then
    echo "Error: No existing claim token found in nomad/jobs/plex"
    exit 1
fi

echo "Writing version to Nomad variable (preserving claim token)..."
nomad var put -force nomad/jobs/plex claim_token="$EXISTING_TOKEN" version="$PLEX_VERSION"

echo "Successfully updated Nomad variable nomad/jobs/plex with version: $PLEX_VERSION"
EOF
        destination = "local/update-plex-version.sh"
        perms       = "0755"
      }

      env {
        NOMAD_ADDR = "http://${attr.unique.network.ip-address}:4646"
      }

      resources {
        cpu    = 100
        memory = 128
      }
    }
  }
}
