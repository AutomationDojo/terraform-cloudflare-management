variable "zone_id" {
  description = "Cloudflare zone ID"
  type        = string
}

variable "records" {
  description = <<-EOT
    List of DNS records to create. Each record is keyed "<type>-<name>", or
    "<type>-<name>-<value>" when several records share type and name; set `key`
    to choose the key yourself. Keys must be unique.
  EOT
  type = list(object({
    key      = optional(string)
    name     = string
    type     = string
    value    = string
    ttl      = optional(number, 1)
    proxied  = optional(bool, false)
    priority = optional(number, null)
  }))
  default = []
}
