# DNS Module

The DNS module provides a simple way to manage DNS records in your Cloudflare zones.

!!! warning "Version 2.0 Upgrade"
    Version 2.0+ uses the `cloudflare_dns_record` resource (required by Cloudflare provider v5). Key changes:
    - Resource renamed from `cloudflare_record` to `cloudflare_dns_record`
    - `name` field now automatically converts `@` to full domain name (FQDN)
    - Subdomains are automatically expanded to FQDN (e.g., `www` becomes `www.example.com`)

    If upgrading from v1.x, see the [migration guide](#migrating-from-v1x) below.

## Features

- **All Record Types**: Support for A, AAAA, CNAME, MX, TXT, SRV, and more
- **Cloudflare Proxy**: Enable/disable Cloudflare proxy per record
- **Configurable TTL**: Set Time To Live for each record
- **Bulk Management**: Manage multiple records efficiently
- **Type Safety**: Validation ensures correct record configuration

## Basic Usage

```hcl
module "dns" {
  source = "git::git@github.com:AutomationDojo/tf-module-cloudflare.git//modules/dns?ref=v2.0.0"

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

## Common Record Types

### A Record (IPv4)

```hcl
module "dns" {
  source  = "git::git@github.com:AutomationDojo/tf-module-cloudflare.git//modules/dns?ref=v2.0.0"
  zone_id = var.cloudflare_zone_id

  records = [
    {
      name    = "api"
      type    = "A"
      value   = "192.0.2.1"
      ttl     = 1
      proxied = true  # Enable Cloudflare proxy for DDoS protection
    }
  ]
}
```

### AAAA Record (IPv6)

```hcl
records = [
  {
    name    = "ipv6"
    type    = "AAAA"
    value   = "2001:0db8:85a3:0000:0000:8a2e:0370:7334"
    ttl     = 1
    proxied = false
  }
]
```

### CNAME Record

```hcl
records = [
  {
    name    = "www"
    type    = "CNAME"
    value   = "example.com"
    ttl     = 1
    proxied = true
  }
]
```

### MX Record (Email)

```hcl
records = [
  {
    name     = "@"
    type     = "MX"
    value    = "mail.example.com"
    ttl      = 1
    proxied  = false  # MX records cannot be proxied
    priority = 10     # Mail server priority
  }
]
```

### TXT Record

```hcl
records = [
  {
    name    = "@"
    type    = "TXT"
    value   = "v=spf1 include:_spf.google.com ~all"
    ttl     = 1
    proxied = false  # TXT records cannot be proxied
  }
]
```

### SRV Record

```hcl
records = [
  {
    name    = "_service._tcp"
    type    = "SRV"
    value   = "target.example.com"
    ttl     = 1
    proxied = false
    priority = 10
    weight   = 5
    port     = 8080
  }
]
```

## Advanced Examples

### Complete Website Setup

```hcl
module "dns" {
  source  = "git::git@github.com:AutomationDojo/tf-module-cloudflare.git//modules/dns?ref=v2.0.0"
  zone_id = var.cloudflare_zone_id

  records = [
    # Root domain
    {
      name    = "@"
      type    = "A"
      value   = "192.0.2.1"
      ttl     = 1
      proxied = true
    },
    # WWW subdomain
    {
      name    = "www"
      type    = "CNAME"
      value   = "example.com"
      ttl     = 1
      proxied = true
    },
    # API subdomain
    {
      name    = "api"
      type    = "A"
      value   = "192.0.2.2"
      ttl     = 1
      proxied = true
    },
    # Mail server
    {
      name     = "@"
      type     = "MX"
      value    = "mail.example.com"
      ttl      = 1
      proxied  = false
      priority = 10
    },
    # SPF record
    {
      name    = "@"
      type    = "TXT"
      value   = "v=spf1 mx ~all"
      ttl     = 1
      proxied = false
    }
  ]
}
```

### Multi-Environment Setup

```hcl
module "dns_production" {
  source  = "git::git@github.com:AutomationDojo/tf-module-cloudflare.git//modules/dns?ref=v2.0.0"
  zone_id = var.cloudflare_zone_id

  records = [
    {
      name    = "app"
      type    = "CNAME"
      value   = "prod-lb.example.com"
      ttl     = 1
      proxied = true
    }
  ]
}

module "dns_staging" {
  source  = "git::git@github.com:AutomationDojo/tf-module-cloudflare.git//modules/dns?ref=v2.0.0"
  zone_id = var.cloudflare_zone_id

  records = [
    {
      name    = "staging"
      type    = "CNAME"
      value   = "staging-lb.example.com"
      ttl     = 1
      proxied = true
    }
  ]
}
```

### Geographic Load Balancing

```hcl
records = [
  # US endpoint
  {
    name    = "us-api"
    type    = "A"
    value   = "192.0.2.1"
    ttl     = 300
    proxied = true
  },
  # EU endpoint
  {
    name    = "eu-api"
    type    = "A"
    value   = "192.0.2.2"
    ttl     = 300
    proxied = true
  },
  # Asia endpoint
  {
    name    = "asia-api"
    type    = "A"
    value   = "192.0.2.3"
    ttl     = 300
    proxied = true
  }
]
```

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| `zone_id` | Cloudflare zone ID | `string` | Yes |
| `records` | List of DNS records to create | `list(object)` | No (default: `[]`) |

### Record Object

| Field | Description | Type | Required | Default |
|-------|-------------|------|----------|---------|
| `name` | Record name (use `@` for root) | `string` | Yes | - |
| `type` | DNS record type | `string` | Yes | - |
| `value` | Record value/target | `string` | Yes | - |
| `ttl` | Time to live in seconds (1 = automatic) | `number` | No | `1` |
| `proxied` | Enable Cloudflare proxy | `bool` | No | `false` |
| `priority` | Priority (MX, SRV records) | `number` | No | - |
| `weight` | Weight (SRV records) | `number` | No | - |
| `port` | Port (SRV records) | `number` | No | - |

## Outputs

| Name | Description |
|------|-------------|
| `records` | Map of all created DNS records |

### Example Output Usage

```hcl
output "dns_records" {
  description = "All DNS records"
  value       = module.dns.records
}
```

## Understanding Cloudflare Proxy

When `proxied = true`:

- **DDoS Protection**: Traffic routed through Cloudflare's network
- **SSL/TLS**: Automatic SSL certificate and encryption
- **Performance**: CDN caching and optimization
- **Analytics**: Detailed traffic analytics
- **Limitations**: Only works for HTTP/HTTPS traffic (A, AAAA, CNAME)

When `proxied = false`:

- **Direct Connection**: DNS points directly to your server
- **Required For**: MX, TXT, SRV, and non-HTTP services
- **Use Cases**: Email servers, SSH, FTP, custom protocols

## TTL Configuration

| TTL Value | Description | Use Case |
|-----------|-------------|----------|
| `1` | Automatic | Cloudflare manages TTL (recommended for proxied records) |
| `300` | 5 minutes | Frequently changing records |
| `3600` | 1 hour | Standard configuration |
| `86400` | 24 hours | Stable, rarely changing records |

!!! tip "TTL Best Practice"
    For proxied records, use `ttl = 1` (automatic). For non-proxied records, use higher values to reduce DNS queries.

## Important Notes

!!! warning "Root Domain (@)"
    Use `@` as the name for records at the root domain (e.g., `example.com` instead of a subdomain).

!!! info "Proxy Limitations"
    Only A, AAAA, and CNAME records can be proxied. Other record types (MX, TXT, SRV) must have `proxied = false`.

!!! tip "Wildcards"
    You can use wildcards: `name = "*"` creates a wildcard record matching all subdomains.

## Prerequisites

1. Domain added to Cloudflare
2. Nameservers pointing to Cloudflare
3. Zone ID from Cloudflare dashboard

## Migrating from v1.x

If you're upgrading from v1.x to v2.0+, the DNS resource name changed from `cloudflare_record` to `cloudflare_dns_record` due to Cloudflare provider v5 requirements.

### Key Changes in v2.0

1. **Resource Renamed**: `cloudflare_record` → `cloudflare_dns_record`
2. **FQDN Required**: The `name` field now uses fully qualified domain names
   - `@` is automatically converted to your domain (e.g., `example.com`)
   - Subdomains are automatically expanded (e.g., `www` → `www.example.com`)
   - **No configuration change needed** - the module handles this automatically

### Migration Steps

1. **Update module version** in your configuration:
   ```hcl
   source = "git::git@github.com:AutomationDojo/tf-module-cloudflare.git//modules/dns?ref=v2.0.0"
   ```

2. **Update Terraform state** for each DNS record:
   ```bash
   # List your current records
   terraform state list | grep cloudflare_record

   # For each record, move to new resource name
   terraform state mv \
     'module.dns.cloudflare_record.records["A-www"]' \
     'module.dns.cloudflare_dns_record.records["A-www"]'
   ```

3. **Verify** the migration:
   ```bash
   terraform plan
   # Should show no changes if migration was successful
   ```

!!! tip "No Configuration Changes"
    You can continue using `@` for root domain and subdomain names (e.g., `www`) in your configuration. The module automatically converts them to FQDN format required by provider v5.

!!! info "Automated Migration"
    Cloudflare provides a [GritQL migration tool](https://github.com/cloudflare/terraform-provider-cloudflare#migration) that can automate state migrations, though it may not work with all module configurations.

## Related

- [Pages Module](pages.md) - Works great with custom domains
- [Email Module](email.md) - Automatic MX record management
- [Cloudflare DNS Documentation](https://developers.cloudflare.com/dns/)
- [Cloudflare Provider v5 Upgrade Guide](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/guides/version-5-upgrade)
