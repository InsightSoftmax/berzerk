packer {
  required_version = ">= 1.4.2"
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }
}

variable "aws_access_key" {
  type    = string
  default = ""
}

variable "aws_region" {
  type    = string
  default = ""
}

variable "aws_secret_key" {
  type    = string
  default = ""
}

variable "instance_type" {
  type        = string
  default     = "t3.medium"
  description = "Instance type to use for the build"
}

variable "ami_name" {
  type        = string
  default     = "helix-ai-{{isotime \"20060102-1504\"}}"
  description = "Name of the resulting AMI"
}

variable "ssh_username" {
  type        = string
  default     = "ubuntu"
  description = "SSH username to connect to the instance"
}

data "amazon-ami" "ubuntu" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.aws_region
  filters = {
    name                = "ubuntu/images/*ubuntu-noble-24.04-amd64-server-*"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = ["099720109477"] # Canonical's AWS account ID
}

source "amazon-ebs" "helix" {
  access_key    = var.aws_access_key
  secret_key    = var.aws_secret_key
  region        = var.aws_region
  instance_type = var.instance_type

  source_ami   = data.amazon-ami.ubuntu.id
  ssh_username = var.ssh_username
  ami_name     = var.ami_name

  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
  }
}

build {
  name    = "helix-ai"
  sources = ["source.amazon-ebs.helix"]

  provisioner "file" {
    source      = "packer-helper.sh"
    destination = "/tmp/packer-helper.sh"
  }

  provisioner "file" {
    source      = "helix.sh"
    destination = "/tmp/helix.sh"
  }

  provisioner "file" {
    source      = "helix-startup.sh"
    destination = "/tmp/helix-startup.sh"
  }

  provisioner "shell" {
    inline = [
      "sudo mv /tmp/packer-helper.sh /root/packer-helper.sh",
      "sudo mv /tmp/helix.sh /root/helix.sh",
      "sudo mv /tmp/helix-startup.sh /opt/helix-startup.sh",
      "sudo chmod +x /root/packer-helper.sh /root/helix.sh /opt/helix-startup.sh",
      "sudo /root/helix.sh"
    ]
  }
}
