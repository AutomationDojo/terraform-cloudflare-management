variable "account_id" {
  description = "Cloudflare account ID"
  type        = string
}

variable "projects" {
  description = "Map of Cloudflare Pages projects to create"
  type = map(object({
    name                       = string
    production_branch          = string
    github_owner               = string
    github_repo                = string
    build_command              = string
    destination_dir            = string
    root_dir                   = optional(string, "")
    custom_domain              = optional(string)
    preview_deployment_setting = optional(string, "none")
    preview_branch_includes    = optional(list(string), [])
    deployment_configs = optional(map(object({
      environment_variables = optional(map(string), {})
      compatibility_date    = optional(string, "2024-01-01")
      compatibility_flags   = optional(list(string), [])
    })), {})
  }))
}
