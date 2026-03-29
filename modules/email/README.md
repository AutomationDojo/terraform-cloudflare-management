# Cloudflare Email Routing Module

Terraform module for managing Cloudflare Email Routing to forward emails from your domain to destination addresses.

## Features

- 📧 Enable/disable email routing for a zone
- 📬 Configure destination email addresses
- 📮 Create email forwarding rules with matchers and actions
- 🎯 Priority-based rule ordering
- 🔄 Support for multiple matchers per rule (literal, wildcard, regex)
- ⚡ Flexible actions (forward, drop, worker)

## Usage

### Basic Example

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
            value = "contact@automationdojo.com"
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

### Advanced Example with Multiple Rules

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
      },
      {
        email = "support@example.com"
      }
    ]

    rules = [
      # High priority - specific addresses
      {
        name     = "Forward contact emails"
        enabled  = true
        priority = 0
        matchers = [
          {
            type  = "literal"
            field = "to"
            value = "contact@automationdojo.com"
          }
        ]
        actions = [
          {
            type  = "forward"
            value = ["admin@example.com"]
          }
        ]
      },
      {
        name     = "Forward support emails"
        enabled  = true
        priority = 1
        matchers = [
          {
            type  = "literal"
            field = "to"
            value = "support@automationdojo.com"
          }
        ]
        actions = [
          {
            type  = "forward"
            value = ["support@example.com"]
          }
        ]
      },
      # Lower priority - catch all
      {
        name     = "Catch all emails"
        enabled  = true
        priority = 100
        matchers = [
          {
            type  = "wildcard"
            field = "to"
            value = "*@automationdojo.com"
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

## Matcher Types

- **literal**: Exact string match
- **wildcard**: Pattern matching using `*` and `?` wildcards
- **regex**: Regular expression matching

## Matcher Fields

- **to**: Match against recipient email address
- **from**: Match against sender email address
- **subject**: Match against email subject line

## Action Types

- **forward**: Forward the email to specified addresses
- **drop**: Drop/reject the email
- **worker**: Process with a Cloudflare Worker

## Important Notes

1. **Email Verification**: All destination addresses must be verified by Cloudflare before they can receive forwarded emails. Cloudflare will automatically send verification emails.

2. **MX Records**: When email routing is enabled, Cloudflare automatically manages MX records for your domain. Any existing MX records will be overridden.

3. **Priority**: Rules are evaluated in priority order (lower numbers first). The first matching rule is applied.

4. **Account ID**: The `account_id` is optional but recommended. If not provided, Terraform will attempt to use the default account associated with the zone.

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
| [cloudflare_email_routing_address.addresses](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/email_routing_address) | resource |
| [cloudflare_email_routing_rule.rules](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/email_routing_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | Cloudflare account ID | `string` | `null` | no |
| <a name="input_email_routing"></a> [email\_routing](#input\_email\_routing) | Email routing configuration | <pre>object({<br/>    enabled = bool<br/>    rules = list(object({<br/>      name     = string<br/>      matchers = list(object({<br/>        type  = string<br/>        field = string<br/>        value = string<br/>      }))<br/>      actions = list(object({<br/>        type  = string<br/>        value = list(string)<br/>      }))<br/>      enabled  = optional(bool, true)<br/>      priority = optional(number, 0)<br/>    }))<br/>    addresses = optional(list(object({<br/>      email = string<br/>    })), [])<br/>  })</pre> | <pre>{<br/>  "addresses": [],<br/>  "enabled": false,<br/>  "rules": []<br/>}</pre> | no |
| <a name="input_zone_id"></a> [zone\_id](#input\_zone\_id) | Cloudflare zone ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_email_addresses"></a> [email\_addresses](#output\_email\_addresses) | Map of email addresses created |
| <a name="output_email_routing_status"></a> [email\_routing\_status](#output\_email\_routing\_status) | Email routing status (managed manually or via API) |
| <a name="output_email_rules"></a> [email\_rules](#output\_email\_rules) | Map of email routing rules created |
<!-- END_TF_DOCS -->
