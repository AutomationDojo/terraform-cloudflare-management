# Quick Start

This guide will help you deploy your first resources using the Cloudflare Terraform Module.

## Basic Setup

### 1. Create a Terraform Configuration

Create a new file `main.tf`:

```hcl
terraform {
  required_version = ">= 1.0"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
```

### 2. Define Variables

Create `variables.tf`:

```hcl
variable "cloudflare_api_token" {
  description = "Cloudflare API token"
  type        = string
  sensitive   = true
}

variable "cloudflare_account_id" {
  description = "Cloudflare account ID"
  type        = string
}

variable "cloudflare_zone_id" {
  description = "Cloudflare zone ID"
  type        = string
}
```

## Example 1: Deploy a Cloudflare Pages Site

Add to your `main.tf`:

```hcl
module "pages" {
  source = "AutomationDojo/management/cloudflare//modules/pages"
  version = "2.3.0"

  account_id = var.cloudflare_account_id

  projects = {
    my-blog = {
      name              = "my-blog"
      production_branch = "main"
      github_owner      = "my-username"
      github_repo       = "my-blog"
      build_command     = "npm run build"
      destination_dir   = "public"
      custom_domain     = "blog.example.com"
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

## Example 2: Create DNS Records

```hcl
module "dns" {
  source = "AutomationDojo/management/cloudflare//modules/dns"
  version = "2.3.0"

  zone_id = var.cloudflare_zone_id

  records = [
    {
      name    = "www"
      type    = "CNAME"
      value   = "example.com"
      ttl     = 1
      proxied = true
    },
    {
      name    = "api"
      type    = "A"
      value   = "192.0.2.1"
      ttl     = 1
      proxied = true
    }
  ]
}
```

## Example 3: Set Up Email Routing

```hcl
module "email" {
  source = "AutomationDojo/management/cloudflare//modules/email"
  version = "2.3.0"

  zone_id    = var.cloudflare_zone_id
  account_id = var.cloudflare_account_id

  email_routing = {
    enabled = true
    addresses = [
      {
        email = "admin@example.com"
      }
    ]
    rules = [
      {
        name     = "Forward contact emails"
        enabled  = true
        priority = 0
        matchers = [
          {
            type  = "literal"
            field = "to"
            value = "contact@yourdomain.com"
          }
        ]
        actions = [
          {
            type  = "forward"
            value = ["admin@example.com"]
          }
        ]
      }
    ]
  }
}
```

## Deploy Your Configuration

### 1. Initialize Terraform

```bash
terraform init
```

### 2. Preview Changes

```bash
terraform plan
```

### 3. Apply Configuration

```bash
terraform apply
```

Review the changes and type `yes` to confirm.

## View Outputs

After applying, you can view the outputs:

```bash
terraform output
```

## Clean Up

To destroy all resources:

```bash
terraform destroy
```

!!! warning
    This will delete all resources managed by this Terraform configuration.

## Next Steps

- [Pages Module Documentation](../modules/pages.md)
- [DNS Module Documentation](../modules/dns.md)
- [Email Module Documentation](../modules/email.md)
- [Complete Setup Example](../examples/complete-setup.md)
