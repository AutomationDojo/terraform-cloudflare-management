variable "zone_id" {
  description = "Cloudflare zone ID"
  type        = string
}

variable "records" {
  description = "List of DNS records to create"
  type = list(object({
    name     = string
    type     = string
    value    = string
    ttl      = optional(number, 1)
    proxied  = optional(bool, false)
    priority = optional(number, null)
  }))
  default = []
}
