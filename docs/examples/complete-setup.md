# Complete Setup Example

This example demonstrates a complete Cloudflare infrastructure setup using all three modules together.

## Scenario

We're setting up infrastructure for a SaaS company with:

- **Marketing website** hosted on Cloudflare Pages
- **Documentation site** hosted on Cloudflare Pages
- **DNS records** for various services
- **Email routing** for company email addresses

## Directory Structure

```
terraform/
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars (gitignored)
└── README.md
```

## Configuration Files

### main.tf

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

# ============================================================================
# Cloudflare Pages - Marketing Website
# ============================================================================

module "pages_marketing" {
  source = "git::git@github.com:AutomationDojo/tf-module-cloudflare.git//modules/pages?ref=v2.0.0"

  account_id = var.cloudflare_account_id

  projects = {
    marketing = {
      name              = "company-marketing"
      production_branch = "main"
      github_repo       = "company/marketing-site"
      build_command     = "npm run build"
      destination_dir   = "dist"
      custom_domain     = "www.example.com"
      environment_variables = {
        NODE_VERSION = "20"
        NPM_VERSION  = "10"
      }
    }
  }
}

# ============================================================================
# Cloudflare Pages - Documentation
# ============================================================================

module "pages_docs" {
  source = "git::git@github.com:AutomationDojo/tf-module-cloudflare.git//modules/pages?ref=v2.0.0"

  account_id = var.cloudflare_account_id

  projects = {
    documentation = {
      name              = "company-docs"
      production_branch = "main"
      github_repo       = "company/docs"
      build_command     = "mkdocs build"
      destination_dir   = "site"
      custom_domain     = "docs.example.com"
      environment_variables = {
        PYTHON_VERSION = "3.11"
      }
    }
  }
}

# ============================================================================
# DNS Records
# ============================================================================

module "dns" {
  source = "git::git@github.com:AutomationDojo/tf-module-cloudflare.git//modules/dns?ref=v2.0.0"

  zone_id = var.cloudflare_zone_id

  records = [
    # Root domain - redirect to www
    {
      name    = "@"
      type    = "A"
      value   = "192.0.2.1"
      ttl     = 1
      proxied = true
    },

    # API server
    {
      name    = "api"
      type    = "A"
      value   = "192.0.2.10"
      ttl     = 1
      proxied = true
    },

    # Database (not proxied - direct connection)
    {
      name    = "db"
      type    = "A"
      value   = "192.0.2.20"
      ttl     = 3600
      proxied = false
    },

    # Status page
    {
      name    = "status"
      type    = "CNAME"
      value   = "status-page.provider.com"
      ttl     = 1
      proxied = true
    },

    # Regional API endpoints
    {
      name    = "us-api"
      type    = "A"
      value   = "192.0.2.30"
      ttl     = 300
      proxied = true
    },
    {
      name    = "eu-api"
      type    = "A"
      value   = "192.0.2.31"
      ttl     = 300
      proxied = true
    },

    # SPF record for email
    {
      name    = "@"
      type    = "TXT"
      value   = "v=spf1 include:_spf.mx.cloudflare.net ~all"
      ttl     = 3600
      proxied = false
    },

    # DKIM record
    {
      name    = "cloudflare._domainkey"
      type    = "TXT"
      value   = "v=DKIM1; p=MIGfMA0GCSqGSIb3DQEBAQUAA..."
      ttl     = 3600
      proxied = false
    }
  ]
}

# ============================================================================
# Email Routing
# ============================================================================

module "email" {
  source = "git::git@github.com:AutomationDojo/tf-module-cloudflare.git//modules/email?ref=v2.0.0"

  zone_id    = var.cloudflare_zone_id
  account_id = var.cloudflare_account_id

  email_routing = {
    enabled = true

    # Destination addresses (need to be verified)
    addresses = [
      {
        email = "admin@personal-email.com"
      },
      {
        email = "support-team@personal-email.com"
      },
      {
        email = "sales-team@personal-email.com"
      }
    ]

    # Routing rules
    rules = [
      # Contact form
      {
        name     = "Contact form submissions"
        enabled  = true
        priority = 0
        matchers = [
          {
            type  = "literal"
            field = "to"
            value = "contact@example.com"
          }
        ]
        actions = [
          {
            type  = "forward"
            value = ["admin@personal-email.com"]
          }
        ]
      },

      # Support emails
      {
        name     = "Support requests"
        enabled  = true
        priority = 1
        matchers = [
          {
            type  = "literal"
            field = "to"
            value = "support@example.com"
          }
        ]
        actions = [
          {
            type  = "forward"
            value = ["support-team@personal-email.com"]
          }
        ]
      },

      # Sales emails
      {
        name     = "Sales inquiries"
        enabled  = true
        priority = 2
        matchers = [
          {
            type  = "literal"
            field = "to"
            value = "sales@example.com"
          }
        ]
        actions = [
          {
            type  = "forward"
            value = ["sales-team@personal-email.com"]
          }
        ]
      },

      # Info emails
      {
        name     = "General information"
        enabled  = true
        priority = 3
        matchers = [
          {
            type  = "literal"
            field = "to"
            value = "info@example.com"
          }
        ]
        actions = [
          {
            type  = "forward"
            value = ["admin@personal-email.com"]
          }
        ]
      },

      # Catch-all (lowest priority)
      {
        name     = "Catch all emails"
        enabled  = true
        priority = 100
        matchers = [
          {
            type  = "wildcard"
            field = "to"
            value = "*@example.com"
          }
        ]
        actions = [
          {
            type  = "forward"
            value = ["admin@personal-email.com"]
          }
        ]
      }
    ]
  }
}
```

### variables.tf

```hcl
variable "cloudflare_api_token" {
  description = "Cloudflare API token with required permissions"
  type        = string
  sensitive   = true
}

variable "cloudflare_account_id" {
  description = "Cloudflare account ID"
  type        = string
}

variable "cloudflare_zone_id" {
  description = "Cloudflare zone ID for example.com"
  type        = string
}
```

### outputs.tf

```hcl
# ============================================================================
# Pages Outputs
# ============================================================================

output "marketing_site_url" {
  description = "Marketing website URL"
  value       = module.pages_marketing.custom_domains["marketing"]
}

output "marketing_site_default_url" {
  description = "Marketing website pages.dev URL"
  value       = module.pages_marketing.default_urls["marketing"]
}

output "docs_site_url" {
  description = "Documentation website URL"
  value       = module.pages_docs.custom_domains["documentation"]
}

output "docs_site_default_url" {
  description = "Documentation pages.dev URL"
  value       = module.pages_docs.default_urls["documentation"]
}

# ============================================================================
# DNS Outputs
# ============================================================================

output "dns_records" {
  description = "All DNS records created"
  value       = module.dns.records
  sensitive   = true
}

# ============================================================================
# Email Routing Outputs
# ============================================================================

output "email_routing_status" {
  description = "Email routing configuration status"
  value = {
    enabled           = module.email.email_routing.enabled
    addresses_count   = length(module.email.email_routing.addresses)
    rules_count       = length(module.email.email_routing.rules)
  }
}
```

### terraform.tfvars

```hcl
# Add to .gitignore!
cloudflare_api_token  = "your-api-token-here"
cloudflare_account_id = "your-account-id"
cloudflare_zone_id    = "your-zone-id"
```

## Deployment Steps

### 1. Initialize Terraform

```bash
terraform init
```

### 2. Review the Plan

```bash
terraform plan
```

Expected output will show:
- 2 Cloudflare Pages projects
- 2 custom domain configurations
- 8+ DNS records
- Email routing configuration with 5 rules

### 3. Apply Configuration

```bash
terraform apply
```

Type `yes` when prompted.

### 4. Verify Email Addresses

After applying:

1. Check email inboxes for verification emails from Cloudflare
2. Click verification links in each email
3. Wait for verification to complete

### 5. View Outputs

```bash
terraform output
```

Example output:
```
marketing_site_url = "www.example.com"
marketing_site_default_url = "company-marketing.pages.dev"
docs_site_url = "docs.example.com"
docs_site_default_url = "company-docs.pages.dev"
email_routing_status = {
  enabled = true
  addresses_count = 3
  rules_count = 5
}
```

## Testing

### Test Pages Deployments

1. Push to your GitHub repositories
2. Watch automatic deployments in Cloudflare dashboard
3. Visit your custom domains

### Test DNS Records

```bash
# Test A record
dig @1.1.1.1 api.example.com

# Test CNAME
dig @1.1.1.1 status.example.com

# Test TXT (SPF)
dig @1.1.1.1 example.com TXT
```

### Test Email Routing

Send test emails to:
- `contact@example.com`
- `support@example.com`
- `sales@example.com`
- `random@example.com` (catch-all)

Verify they arrive at the correct destination addresses.

## Maintenance

### Update to Latest Version

```bash
# Update module version in main.tf
# Change ref=v2.0.0 to ref=v2.0.0

terraform init -upgrade
terraform plan
terraform apply
```

### Add New DNS Record

```hcl
# In main.tf, add to dns module's records list:
{
  name    = "staging"
  type    = "A"
  value   = "192.0.2.50"
  ttl     = 1
  proxied = true
}
```

Then apply:
```bash
terraform apply
```

### Add New Email Rule

```hcl
# In main.tf, add to email module's rules list:
{
  name     = "Billing emails"
  enabled  = true
  priority = 4
  matchers = [
    {
      type  = "literal"
      field = "to"
      value = "billing@example.com"
    }
  ]
  actions = [
    {
      type  = "forward"
      value = ["billing@personal-email.com"]
    }
  ]
}
```

## Best Practices Demonstrated

1. **Module Versioning**: Using specific version tags (`ref=v2.0.0`)
2. **Separation of Concerns**: Each module handles one area
3. **Environment Variables**: Properly configured for Pages builds
4. **DNS Organization**: Clear naming and purpose for each record
5. **Email Priority**: Specific rules before catch-all
6. **Security**: API token in separate file (gitignored)
7. **Documentation**: Clear outputs for easy reference

## Cost Considerations

This setup uses Cloudflare's free tier:

- **Pages**: 500 builds/month (free)
- **DNS**: Unlimited records (free)
- **Email Routing**: 200 destination addresses (free)
- **SSL/TLS**: Automatic (free)
- **DDoS Protection**: Included (free)

## Next Steps

- Set up [Terraform Cloud](https://cloud.hashicorp.com/products/terraform) for remote state
- Add monitoring and alerts
- Implement GitOps workflow with CI/CD
- Add more environments (staging, development)
- Configure Cloudflare Access for internal tools
