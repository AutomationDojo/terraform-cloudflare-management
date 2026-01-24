# Modules Overview

The Cloudflare Terraform Module is organized into four main submodules, each focused on a specific area of Cloudflare functionality.

## Available Modules

### Pages Module

Manage Cloudflare Pages projects for static site hosting with automatic CI/CD.

**Key Features:**

- GitHub integration for automatic deployments
- Custom domain support with SSL/TLS
- Environment variables configuration
- Production and preview environments

[View Pages Documentation →](pages.md)

---

### DNS Module

Create and manage DNS records for your Cloudflare zones.

**Key Features:**

- Support for all DNS record types
- Cloudflare proxy support
- Configurable TTL
- Bulk record management

[View DNS Documentation →](dns.md)

---

### Email Routing Module

Set up email forwarding and routing rules for your domains.

**Key Features:**

- Email forwarding to external addresses
- Rule-based routing with matchers
- Priority-based rule ordering
- Support for literal, wildcard, and regex patterns

[View Email Documentation →](email.md)

---

### R2 Storage Module

Manage Cloudflare R2 object storage buckets with S3-compatible access.

**Key Features:**

- S3-compatible object storage
- Zero egress fees
- Configurable bucket locations (eeur, weur, enam, wnam, apac)
- Data jurisdiction control (eu, us, apac)
- Storage class optimization (Standard, InfrequentAccess)

[View R2 Documentation →](r2.md)

---

## Module Design Philosophy

Each module is designed to be:

- **Independent**: Use only the modules you need
- **Composable**: Combine modules for complete infrastructure
- **Type-safe**: Strongly typed with validation
- **Well-documented**: Clear examples and documentation

## Using Multiple Modules

You can combine modules in a single Terraform configuration:

```hcl
# Deploy a Pages site
module "pages" {
  source = "git::git@github.com:AutomationDojo/tf-module-cloudflare.git//modules/pages?ref=v2.0.0"
  # ... configuration
}

# Configure DNS
module "dns" {
  source = "git::git@github.com:AutomationDojo/tf-module-cloudflare.git//modules/dns?ref=v2.0.0"
  # ... configuration
}

# Set up email routing
module "email" {
  source = "git::git@github.com:AutomationDojo/tf-module-cloudflare.git//modules/email?ref=v2.0.0"
  # ... configuration
}

# Create R2 storage buckets
module "r2" {
  source = "git::git@github.com:AutomationDojo/tf-module-cloudflare.git//modules/r2?ref=v2.0.0"
  # ... configuration
}
```

See the [Complete Setup Example](../examples/complete-setup.md) for a full configuration.
