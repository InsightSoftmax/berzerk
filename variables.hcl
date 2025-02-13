variable "vultr_api_key" {
  type      = string
  default   = "${env("VULTR_API_KEY")}"
  sensitive = true
}

variable "os_id" {
  type      = string
  default   = "${env("VULTR_OS_ID")}" # Ubuntu 20.04 x64
}

variable "plan_id" {
  type      = string
  default   = "${env("VULTR_PLAN_ID")}"
}

