# Build env_vars for each project and environment in the format expected by cloudflare_pages_project:
# map of key => { value = string, type = "plain_text" | "secret" }
# Merges simple environment_variables (map string, treated as plain_text) with full env_vars (object with type).
locals {
  production_env_vars = {
    for pk, p in var.projects : pk => merge(
      {
        for k, v in try(p.deployment_configs.production.environment_variables, {}) :
        k => { value = try(p.deployment_configs.production.env_vars[k].value, v), type = try(p.deployment_configs.production.env_vars[k].type, "plain_text") }
      },
      try(p.deployment_configs.production.env_vars, {})
    )
  }
  preview_env_vars = {
    for pk, p in var.projects : pk => merge(
      {
        for k, v in try(p.deployment_configs.preview.environment_variables, {}) :
        k => { value = try(p.deployment_configs.preview.env_vars[k].value, v), type = try(p.deployment_configs.preview.env_vars[k].type, "plain_text") }
      },
      try(p.deployment_configs.preview.env_vars, {})
    )
  }
}
