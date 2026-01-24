variable "account_id" {
  description = "Cloudflare account ID"
  type        = string
}

variable "buckets" {
  description = "List of R2 buckets to create"
  type = list(object({
    name     = string
    location = optional(string, "EEUR")
  }))
  default = []
}
