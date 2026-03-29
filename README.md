# Cloudflare Terraform Module

Comprehensive Terraform module for managing Cloudflare resources with modular submodules.

## Features

- 📄 **Pages** - Cloudflare Pages projects management
- 🌐 **DNS** - DNS records management
- 📧 **Email Routing** - Email forwarding and routing rules
- 💾 **R2 Storage** - R2 object storage buckets management
- 🔒 **Tunnel** - Cloudflare Tunnels for secure origin connectivity
- 🔄 **Automated Versioning** - Semantic release integration
- 📝 **Auto-generated Docs** - Terraform-docs integration

## Submodules

- **[pages](./modules/pages/)** - Cloudflare Pages projects
- **[dns](./modules/dns/)** - DNS records management
- **[email](./modules/email/)** - Email routing and forwarding
- **[r2](./modules/r2/)** - R2 object storage buckets
- **[tunnel](./modules/tunnel/)** - Cloudflare Tunnels

## Quick Start

### Pages Module

```hcl
module "pages" {
  source = "AutomationDojo/management/cloudflare//modules/pages"
  version = "2.3.0"

  account_id = var.cloudflare_account_id

  projects = {
    my-site = {
      name              = "my-site"
      production_branch = "main"
      github_owner      = "my-org"
      github_repo       = "my-repo"
      build_command     = "npm run build"
      destination_dir   = "dist"
      custom_domain     = "example.com"
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

### DNS Module

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
    }
  ]
}
```

### Email Routing Module

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

### R2 Storage Module

```hcl
module "r2" {
  source = "AutomationDojo/management/cloudflare//modules/r2"
  version = "2.3.0"

  account_id = var.cloudflare_account_id

  buckets = [
    {
      name          = "my-storage-bucket"
      location      = "eeur"
      jurisdiction  = "eu"
      storage_class = "Standard"
    }
  ]
}
```

### Tunnel Module

```hcl
module "tunnel" {
  source = "AutomationDojo/management/cloudflare//modules/tunnel"
  version = "2.3.0"

  account_id = var.cloudflare_account_id

  tunnels = {
    my-tunnel = {
      name = "my-app-tunnel"
      ingress_rules = [
        {
          hostname = "app.example.com"
          service  = "http://localhost:8080"
        },
        {
          service = "http_status:404"
        }
      ]
    }
  }
}
```

## Documentation

Full documentation is available at: **https://automationdojo.github.io/tf-module-cloudflare**

- [Getting Started](https://automationdojo.github.io/tf-module-cloudflare/getting-started/installation/)
- [Modules Documentation](https://automationdojo.github.io/tf-module-cloudflare/modules/)
- [Complete Examples](https://automationdojo.github.io/tf-module-cloudflare/examples/complete-setup/)

### Local Documentation

To view the documentation locally:

```bash
# Install dependencies
pip install -r requirements.txt

# Serve documentation locally
mkdocs serve

# Open http://127.0.0.1:8000 in your browser
```


## Examples

See [examples](./examples/) directory for complete usage examples.

## Requirements

- Terraform >= 1.0
- Cloudflare Provider ~> 5.0

## License

MIT
