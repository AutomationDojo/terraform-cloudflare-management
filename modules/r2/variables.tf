variable "account_id" {
  description = "Cloudflare account ID"
  type        = string
}
variable "buckets" {
  description = "List of R2 buckets to create"
  type = list(object({
    name          = string
    location      = optional(string, "eeur")
    jurisdiction  = optional(string, "eu")
    storage_class = optional(string, "Standard")
    cors_rules = optional(list(object({
      id              = optional(string)
      allowed_methods = list(string)
      allowed_origins = list(string)
      allowed_headers = optional(list(string))
      expose_headers  = optional(list(string))
      max_age_seconds = optional(number)
    })), [])
    custom_domains = optional(list(object({
      domain  = string
      zone_id = string
      enabled = optional(bool, true)
      min_tls = optional(string)
    })), [])
  }))
  default = []
}
