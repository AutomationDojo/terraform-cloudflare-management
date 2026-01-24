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
      preview_branch_includes        = each.value.preview_branch_includes
    }
  }

  build_config = {
    build_command   = each.value.build_command
    destination_dir = each.value.destination_dir
    root_dir        = each.value.root_dir
  }

  deployment_configs = {
    for env, config in each.value.deployment_configs : env => {
      environment_variables = config.environment_variables
      compatibility_date    = config.compatibility_date
      compatibility_flags   = config.compatibility_flags
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
