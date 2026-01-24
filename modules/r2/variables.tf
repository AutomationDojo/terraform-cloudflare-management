variable "account_id" {
  description = "Cloudflare account ID"
  type        = string
}

variable "buckets" {
  description = "List of R2 buckets to create"
  type = list(object({
    name     = string
    location = optional(string, "eeur")
    jurisdiction = optional(string, "eu")
    storage_class = optional(string, "default")
  }))
  default = []
}
