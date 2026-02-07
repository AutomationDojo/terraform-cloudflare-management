# Cloudflare Terraform Module

Welcome to the Cloudflare Terraform Module documentation! This comprehensive module helps you manage Cloudflare resources using Terraform with a modular, easy-to-use approach.

## Features

- **📄 Pages** - Manage Cloudflare Pages projects with custom domains, build configurations, and environment variables (plain text and secrets)
- **🌐 DNS** - Create and manage DNS records with full control over proxying and TTL
- **📧 Email Routing** - Set up email forwarding and routing rules for your domains
- **💾 R2 Storage** - Manage R2 object storage buckets with jurisdiction and storage class control
- **🔄 Automated Versioning** - Semantic release integration for automated version management
- **📝 Auto-generated Docs** - Terraform-docs integration for always up-to-date module documentation

## Why Use This Module?

This module provides a structured, maintainable way to manage your Cloudflare infrastructure:

- **Modular Design**: Use only what you need - each submodule is independent
- **Best Practices**: Built following Terraform and Cloudflare best practices
- **Well Documented**: Comprehensive examples and documentation for all features
- **Production Ready**: Tested and versioned for reliable deployments
- **Type Safe**: Strongly typed variables with validation

## Quick Example

```hcl
module "cloudflare_pages" {
  source = "git::git@github.com:AutomationDojo/tf-module-cloudflare.git//modules/pages?ref=v2.0.1"

  account_id = var.cloudflare_account_id

  projects = {
    my-website = {
      name              = "my-website"
      production_branch = "main"
      github_owner      = "my-org"
      github_repo       = "my-repo"
      build_command     = "npm run build"
      destination_dir   = "dist"
      custom_domain     = "www.example.com"
      deployment_configs = {
        production = {
          environment_variables = {
            NODE_VERSION = "22"
          }
        }
      }
    }
  }
}
```

## Getting Started

1. [Installation](getting-started/installation.md) - Set up the module in your project
2. [Quick Start](getting-started/quick-start.md) - Get up and running quickly
3. [Modules](modules/index.md) - Explore available modules

## Requirements

| Name | Version |
|------|---------|
| Terraform | >= 1.0 |
| Cloudflare Provider | ~> 5.0 |

## License

MIT License - See LICENSE file for details
