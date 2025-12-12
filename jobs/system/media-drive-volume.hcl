id        = "media-drive"
name      = "media-drive"
type      = "csi"
plugin_id = "smb"

capability {
  access_mode     = "multi-node-multi-writer"
  attachment_mode = "file-system"
}

mount_options {
  fs_type = "cifs"
  mount_flags = ["uid=1002", "gid=1001", "file_mode=0644", "dir_mode=0755", "vers=3.0"]
}

secrets {
  username = "plex"
  password = "<SECRET HERE>"
}

context {
  source = "//10.100.0.1/media"
}
