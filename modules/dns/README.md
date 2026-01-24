# Cloudflare DNS Module

Terraform module for managing Cloudflare DNS records.

## Features

- 📝 Manage multiple DNS records
- 🔄 Support for all DNS record types (A, AAAA, CNAME, MX, TXT, etc.)
- 🌐 Proxy support for HTTP/HTTPS records
- ⚙️ Configurable TTL per record

## Usage

```hcl
module "dns" {
  source = "git::git@github.com:AutomationDojo/tf-module-cloudflare.git//modules/dns?ref=v2.0.1"

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
      name    = "@"
      type    = "A"
      value   = "192.0.2.1"
      ttl     = 1
      proxied = true
    }
  ]
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
| [cloudflare_dns_record.records](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/dns_record) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_records"></a> [records](#input\_records) | List of DNS records to create | <pre>list(object({<br/>    name     = string<br/>    type     = string<br/>    value    = string<br/>    ttl      = optional(number, 1)<br/>    proxied  = optional(bool, false)<br/>    priority = optional(number, null)<br/>  }))</pre> | `[]` | no |
| <a name="input_zone_id"></a> [zone\_id](#input\_zone\_id) | Cloudflare zone ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_records"></a> [records](#output\_records) | Map of DNS records created |
<!-- END_TF_DOCS -->
