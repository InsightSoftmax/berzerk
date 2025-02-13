packer {
  required_plugins {
    vultr = {
      version = ">=v2.3.2"
      source = "github.com/vultr/vultr"
    }
  }
}

source "vultr" "helix" {
  api_key              = "${var.vultr_api_key}"
  os_id                = "${var.os_id}"
  plan_id              = "${var.plan_id}"
  region_id            = "fra"
  snapshot_description = "Helix ${formatdate("YYYY-MM-DD hh:mm", timestamp())}"
  ssh_username         = "root"
  state_timeout        = "25m"
}

build {
  sources = ["source.vultr.helix"]
  provisioner "file" {
    source      = "helix-startup.sh"
    destination = "/opt/helix-startup.sh"
  }
  provisioner "shell" {
    script = "helix.sh"
  }
  post-processor "vultr-snapshot" {
  snapshot_name = "helix-marketplace"
  }
}
