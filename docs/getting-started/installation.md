# Installation

This guide will help you get started with the Cloudflare Terraform Module.

## Prerequisites

Before using this module, ensure you have:

- **Terraform** >= 1.0 installed
- **Cloudflare Account** with API access
- **Git** for module source control

## Cloudflare API Token

You'll need a Cloudflare API token with appropriate permissions:

1. Log in to your [Cloudflare Dashboard](https://dash.cloudflare.com/)
2. Go to **My Profile** > **API Tokens**
3. Click **Create Token**
4. Choose a template or create a custom token with these permissions:
   - **Account** - Cloudflare Pages: Edit
   - **Zone** - DNS: Edit
   - **Zone** - Email Routing Rules: Edit

## Configure Terraform

### 1. Set up the Cloudflare Provider

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

### 2. Store API Token Securely

Create a `terraform.tfvars` file (add to `.gitignore`):

```hcl
cloudflare_api_token  = "your-api-token-here"
cloudflare_account_id = "your-account-id"
cloudflare_zone_id    = "your-zone-id"
```

Or use environment variables:

```bash
export CLOUDFLARE_API_TOKEN="your-api-token-here"
export TF_VAR_cloudflare_account_id="your-account-id"
export TF_VAR_cloudflare_zone_id="your-zone-id"
```

## Module Installation

The module is installed directly from GitHub. No separate download is needed - Terraform handles this automatically.

### Using Specific Versions

It's recommended to pin to a specific version:

```hcl
module "cloudflare_pages" {
  source = "git::git@github.com:AutomationDojo/tf-module-cloudflare.git//modules/pages?ref=v2.0.1"
  # ... configuration
}
```

### Using Latest

For development or testing, you can use the latest version:

```hcl
module "cloudflare_pages" {
  source = "git::git@github.com:AutomationDojo/tf-module-cloudflare.git//modules/pages?ref=main"
  # ... configuration
}
```

!!! warning
    Using `ref=main` means you'll get the latest changes, which may include breaking changes.

## Initialize Terraform

After configuring your module sources, initialize Terraform:

```bash
terraform init
```

This will download the module and all required providers.

## Next Steps

- [Quick Start Guide](quick-start.md) - Create your first resources
- [Modules Overview](../modules/index.md) - Explore available modules
- [Examples](../examples/complete-setup.md) - See complete configurations
