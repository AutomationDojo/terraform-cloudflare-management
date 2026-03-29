variable "zone_id" {
  description = "Cloudflare zone ID"
  type        = string
}

variable "account_id" {
  description = "Cloudflare account ID"
  type        = string
  default     = null
}

variable "email_routing" {
  description = "Email routing configuration"
  type = object({
    enabled = bool
    rules = list(object({
      name = string
      matchers = list(object({
        type  = string
        field = string
        value = string
      }))
      actions = list(object({
        type  = string
        value = list(string)
      }))
      enabled  = optional(bool, true)
      priority = optional(number, 0)
    }))
    addresses = optional(list(object({
      email = string
    })), [])
  })
  default = {
    enabled   = false
    rules     = []
    addresses = []
  }
}
