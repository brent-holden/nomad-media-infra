# This job runs the controller service for the SMB CSI plugin.
# The controller is responsible for managing volumes (create, delete, etc.).
job "cifs-csi-plugin-controller" {
  datacenters = ["dc1"]
  type        = "service"

  # The controller group runs a single instance of the plugin.
  group "controller" {
    count = 1

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

      }

      # This stanza configures the task as a CSI plugin controller.
      csi_plugin {
        id   = "smb"
        type = "controller"
        mount_dir = "/csi"
      }

      resources {
        memory = 512
        cpu = 512
      }
    }
  }
}
