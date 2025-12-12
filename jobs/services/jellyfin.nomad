# This job runs the Jellyfin media server.
job "jellyfin" {
  datacenters = ["dc1"]
  type        = "service"

  group "jellyfin" {
    count = 1

    # This volume is for the media library, and is backed by a CSI volume.
    volume "media-drive" {
      type            = "csi"
      source          = "media-drive"
      access_mode     = "multi-node-multi-writer"
      attachment_mode = "file-system"
    }

    # This volume is for the Jellyfin configuration, and is a host volume.
    volume "jellyfin-config" {
      type   = "host"
      source = "jellyfin-config"
    }

    # This volume is for the Jellyfin cache, and is a host volume.
    volume "jellyfin-cache" {
      type   = "host"
      source = "jellyfin-cache"
    }

    network {
      mode = "host"
      port "http" {
        static = 8096
      }
      port "discovery" {
        static = 7359
      }
    }

    task "jellyfin" {
      driver = "podman"

      resources {
        cpu    = 16000
        memory = 16384
      }

      config {
        image        = "docker.io/jellyfin/jellyfin:latest"
        ports        = ["http", "discovery"]
        network_mode = "host"
      }

      volume_mount {
        volume      = "jellyfin-config"
        destination = "/config"
      }

      volume_mount {
        volume      = "jellyfin-cache"
        destination = "/cache"
      }

      volume_mount {
        volume      = "media-drive"
        destination = "/media"
      }

      template {
        data = <<EOH
TZ=America/New_York
EOH
        destination = "local/env_vars"
        env         = true
      }

      service {
        name = "jellyfin"
        port = "http"

        check {
          type     = "http"
          path     = "/health"
          interval = "30s"
          timeout  = "10s"
        }
      }
    }
  }
}
