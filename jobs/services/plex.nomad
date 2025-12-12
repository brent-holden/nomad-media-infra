# This job runs the Plex media server.
job "plex" {
  datacenters = ["dc1"]
  type        = "service"

  # The plex group runs a single instance of the Plex server.
  group "plex" {
    count = 1

    # This volume is for the media library, and is backed by a CSI volume.
    volume "media-drive" {
      type            = "csi"
      source          = "media-drive"
      access_mode     = "multi-node-multi-writer"
      attachment_mode = "file-system"
    }

    # This volume is for the Plex configuration, and is a host volume.
    volume "plex-config" {
      type   = "host"
      source = "plex-config"
    }

    # This volume is for transcoding, and is a host volume.
    volume "plex-transcode" {
      type   = "host"
      source = "plex-transcode"
    }


    # The network stanza configures the job to use the host's network stack.
    network {
      mode = "host"
      port "plex" {
        static = 32400
      }
    }

    task "plex" {
      driver = "podman"

      resources {
        cpu    = 16000
        memory = 16384
      }

      config {
        image        = "docker.io/plexinc/pms-docker:latest"
        ports        = ["plex"]
        network_mode = "host"
        devices = ["/dev/dri:/dev/dri"]
      }

      # The volume_mount stanzas mount the volumes into the container.
      volume_mount {
        volume      = "plex-config"
        destination = "/config"
      }

      volume_mount {
        volume      = "plex-transcode"
        destination = "/transcode"
      }

      volume_mount {
        volume      = "media-drive"
        destination = "/media"
      }

      # The template stanza creates an environment file from Nomad variables.
      template {
        data = <<EOH
TZ=America/New_York
PLEX_CLAIM={{- with nomadVar "nomad/jobs/plex" -}}{{ .claim_token }}{{- end }}
VERSION={{- with nomadVar "nomad/jobs/plex" -}}{{ .version }}{{- end }}
PLEX_UID=1002
PLEX_GID=1001
EOH
        destination = "local/env_vars"
        env         = true
      }

      # The service stanza registers the Plex service with Consul.
      service {
        name = "plex"
        port = "plex"
        
        check {
          type     = "http"
          path     = "/identity"
          interval = "30s"
          timeout  = "10s"
        }
      }
    }
  }
}
