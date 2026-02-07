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
    production_deployments_enabled = optional(bool, true)
    preview_deployment_setting     = optional(string, "none")
    preview_branch_includes    = optional(list(string), [])
    deployment_configs = optional(map(object({
      # Simple key-value env vars (plain text). Merged with env_vars; env_vars takes precedence for same key.
      environment_variables = optional(map(string), {})
      # Full env vars with type (plain_text or secret). Use for secrets or when you need to set type explicitly.
      env_vars = optional(map(object({
        value = string
        type  = optional(string, "plain_text") # "plain_text" or "secret"
      })), {})
      compatibility_date  = optional(string, "2024-01-01")
      compatibility_flags = optional(list(string), [])
    })), {})
  }))
}
