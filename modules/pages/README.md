# Cloudflare Pages Module

Terraform module for creating and managing Cloudflare Pages projects with GitHub integration.

## Features

- 🚀 Creates Cloudflare Pages projects
- 🔗 Automatic GitHub integration for CI/CD
- 🌐 Custom domain support with automatic SSL/TLS
- ⚙️ Environment variables configuration
- 🔄 Production and preview deployments

## Usage

```hcl
module "pages" {
  source = "git::git@github.com:AutomationDojo/tf-module-cloudflare.git//modules/pages?ref=v2.0.0"

  account_id = var.cloudflare_account_id

  projects = {
    landing-page = {
      name              = "my-landing-page"
      production_branch = "main"
      github_repo       = "my-repo"
      build_command     = "npm run build"
      destination_dir   = "dist"
      custom_domain     = "example.com"
      environment_variables = {
        NODE_VERSION = "20"
      }
    }
  }
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_cloudflare"></a> [cloudflare](#requirement\_cloudflare) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_cloudflare"></a> [cloudflare](#provider\_cloudflare) | ~> 5.0 |

## Resources

| Name | Type |
|------|------|
| [cloudflare_pages_domain.domains](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/pages_domain) | resource |
| [cloudflare_pages_project.projects](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/pages_project) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | Cloudflare account ID | `string` | n/a | yes |
| <a name="input_projects"></a> [projects](#input\_projects) | Map of Cloudflare Pages projects to create | <pre>map(object({<br/>    name                       = string<br/>    production_branch          = string<br/>    github_repo                = string<br/>    build_command              = string<br/>    destination_dir            = string<br/>    custom_domain              = optional(string)<br/>    preview_deployment_setting = optional(string, "none")<br/>    environment_variables      = optional(map(string), {})<br/>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_custom_domains"></a> [custom\_domains](#output\_custom\_domains) | Map of custom domains configured |
| <a name="output_default_urls"></a> [default\_urls](#output\_default\_urls) | Map of default pages.dev URLs |
| <a name="output_projects"></a> [projects](#output\_projects) | Map of all Cloudflare Pages projects |
<!-- END_TF_DOCS -->
