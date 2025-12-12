# This job runs the node service for the SMB CSI plugin.
# The node plugin is responsible for mounting volumes on the host.
job "cifs-csi-plugin-node" {
  datacenters = ["dc1"]
  type        = "system"

  # The nodes group runs the plugin on all client nodes.
  group "nodes" {
    task "plugin" {
      driver = "podman"

      config {
        image = "mcr.microsoft.com/k8s/csi/smb-csi:v1.17.0"

        args = [
          "--v=5",
          "--nodeid=${node.unique.id}",
          "--endpoint=unix:///csi/csi.sock",
          "--drivername=smb.csi.k8s.io",
        ]

        privileged   = true
        network_mode = "host"

      }

      # This stanza configures the task as a CSI plugin node service.
      csi_plugin {
        id                     = "smb"
        type                   = "node"
        mount_dir              = "/csi"
        stage_publish_base_dir = "/local/csi"
      }

      resources {
        cpu    = 512
        memory = 512
      }
    }
  }
}
