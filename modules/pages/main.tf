resource "cloudflare_pages_project" "projects" {
  for_each = var.projects

  account_id        = var.account_id
  name              = each.value.name
  production_branch = each.value.production_branch

  source = {
    type = "github"
    config = {
      owner                         = each.value.github_owner
      repo_name                     = each.value.github_repo
      production_branch             = each.value.production_branch
      pr_comments_enabled           = true
      production_deployments_enabled = true
      preview_deployment_setting     = each.value.preview_deployment_setting
      preview_branch_includes        = length(each.value.preview_branch_includes) > 0 ? each.value.preview_branch_includes : null
    }
  }

  build_config = {
    build_command   = each.value.build_command
    destination_dir = each.value.destination_dir
    root_dir        = each.value.root_dir
  }

  deployment_configs = {
    production = {
      environment_variables = lookup(each.value.deployment_configs, "production", null) != null ? each.value.deployment_configs.production.environment_variables : {}
      compatibility_date    = lookup(each.value.deployment_configs, "production", null) != null ? each.value.deployment_configs.production.compatibility_date : "2024-01-01"
      compatibility_flags   = lookup(each.value.deployment_configs, "production", null) != null ? each.value.deployment_configs.production.compatibility_flags : []
      fail_open             = true
    }
    preview = {
      environment_variables = lookup(each.value.deployment_configs, "preview", null) != null ? each.value.deployment_configs.preview.environment_variables : {}
      compatibility_date    = lookup(each.value.deployment_configs, "preview", null) != null ? each.value.deployment_configs.preview.compatibility_date : "2024-01-01"
      compatibility_flags   = lookup(each.value.deployment_configs, "preview", null) != null ? each.value.deployment_configs.preview.compatibility_flags : []
      fail_open             = true
    }
  }
}

# Custom domains (only created if custom_domain is specified)
resource "cloudflare_pages_domain" "domains" {
  for_each = {
    for k, v in var.projects : k => v
    if v.custom_domain != null
  }

  account_id   = var.account_id
  project_name = cloudflare_pages_project.projects[each.key].name
  name         = each.value.custom_domain
}
