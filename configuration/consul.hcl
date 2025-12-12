# Consul Configuration
data_dir  = "/opt/consul/data"
bind_addr = "0.0.0.0"
client_addr = "0.0.0.0"

datacenter = "dc1"

ui_config {
  enabled = true
}

server           = true
bootstrap_expect = 1

# Service mesh
connect {
  enabled = true
}

# DNS
ports {
  dns = 8600
}

# Enable local script checks for Nomad health checks
enable_local_script_checks = true
