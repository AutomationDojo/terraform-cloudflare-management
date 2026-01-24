# Email Routing Module

The Email Routing module enables you to forward emails from your domain to destination addresses using Cloudflare's email routing service.

## Features

- **Email Forwarding**: Forward emails from your domain to any destination address
- **Rule-Based Routing**: Create sophisticated routing rules with matchers
- **Priority System**: Control rule evaluation order with priorities
- **Pattern Matching**: Support for literal, wildcard, and regex patterns
- **Multiple Actions**: Forward, drop, or process with Workers
- **Automatic MX Records**: Cloudflare manages MX records automatically

## Basic Usage

```hcl
module "email" {
  source = "git::git@github.com:AutomationDojo/tf-module-cloudflare.git//modules/email?ref=v2.0.1"

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

## Advanced Examples

### Multiple Forwarding Rules

```hcl
module "email" {
  source = "git::git@github.com:AutomationDojo/tf-module-cloudflare.git//modules/email?ref=v2.0.1"

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
      },
      {
        email = "sales@example.com"
      }
    ]

    rules = [
      # Contact form
      {
        name     = "Contact form emails"
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
      },
      # Support requests
      {
        name     = "Support emails"
        enabled  = true
        priority = 1
        matchers = [
          {
            type  = "literal"
            field = "to"
            value = "support@yourdomain.com"
          }
        ]
        actions = [
          {
            type  = "forward"
            value = ["support@example.com"]
          }
        ]
      },
      # Sales inquiries
      {
        name     = "Sales emails"
        enabled  = true
        priority = 2
        matchers = [
          {
            type  = "literal"
            field = "to"
            value = "sales@yourdomain.com"
          }
        ]
        actions = [
          {
            type  = "forward"
            value = ["sales@example.com"]
          }
        ]
      }
    ]
  }
}
```

### Catch-All with Wildcards

```hcl
module "email" {
  source = "git::git@github.com:AutomationDojo/tf-module-cloudflare.git//modules/email?ref=v2.0.1"

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
      # Specific address - higher priority
      {
        name     = "Contact emails"
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
      },
      # Catch all - lower priority
      {
        name     = "Catch all emails"
        enabled  = true
        priority = 100
        matchers = [
          {
            type  = "wildcard"
            field = "to"
            value = "*@yourdomain.com"
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

### Subject-Based Routing

```hcl
rules = [
  {
    name     = "Urgent emails"
    enabled  = true
    priority = 0
    matchers = [
      {
        type  = "wildcard"
        field = "subject"
        value = "*URGENT*"
      }
    ]
    actions = [
      {
        type  = "forward"
        value = ["urgent@example.com", "admin@example.com"]
      }
    ]
  }
]
```

### Regex Pattern Matching

```hcl
rules = [
  {
    name     = "Team member emails"
    enabled  = true
    priority = 0
    matchers = [
      {
        type  = "regex"
        field = "to"
        value = "^(alice|bob|charlie)@yourdomain\\.com$"
      }
    ]
    actions = [
      {
        type  = "forward"
        value = ["team@example.com"]
      }
    ]
  }
]
```

### Drop Spam

```hcl
rules = [
  {
    name     = "Drop spam"
    enabled  = true
    priority = 0
    matchers = [
      {
        type  = "literal"
        field = "to"
        value = "spam@yourdomain.com"
      }
    ]
    actions = [
      {
        type = "drop"
      }
    ]
  }
]
```

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| `zone_id` | Cloudflare zone ID | `string` | Yes |
| `account_id` | Cloudflare account ID | `string` | Yes |
| `email_routing` | Email routing configuration | `object` | No |

### Email Routing Object

| Field | Description | Type | Required | Default |
|-------|-------------|------|----------|---------|
| `enabled` | Enable email routing | `bool` | No | `true` |
| `addresses` | Destination email addresses | `list(object)` | No | `[]` |
| `rules` | Email routing rules | `list(object)` | No | `[]` |

### Address Object

| Field | Description | Type | Required |
|-------|-------------|------|----------|
| `email` | Destination email address | `string` | Yes |

### Rule Object

| Field | Description | Type | Required | Default |
|-------|-------------|------|----------|---------|
| `name` | Rule name | `string` | Yes | - |
| `enabled` | Enable rule | `bool` | No | `true` |
| `priority` | Rule priority (lower = higher priority) | `number` | Yes | - |
| `matchers` | List of matchers | `list(object)` | Yes | - |
| `actions` | List of actions | `list(object)` | Yes | - |

### Matcher Object

| Field | Description | Type | Required |
|-------|-------------|------|----------|
| `type` | Matcher type: `literal`, `wildcard`, `regex` | `string` | Yes |
| `field` | Field to match: `to`, `from`, `subject` | `string` | Yes |
| `value` | Value/pattern to match | `string` | Yes |

### Action Object

| Field | Description | Type | Required |
|-------|-------------|------|----------|
| `type` | Action type: `forward`, `drop`, `worker` | `string` | Yes |
| `value` | Array of destination emails (for forward) | `list(string)` | Conditional |

## Matcher Types

### Literal

Exact string match. Case-sensitive.

```hcl
{
  type  = "literal"
  field = "to"
  value = "contact@yourdomain.com"
}
```

### Wildcard

Pattern matching using `*` (zero or more characters) and `?` (single character).

```hcl
{
  type  = "wildcard"
  field = "to"
  value = "*@yourdomain.com"  # Matches any address at yourdomain.com
}
```

```hcl
{
  type  = "wildcard"
  field = "subject"
  value = "*invoice*"  # Matches subjects containing "invoice"
}
```

### Regex

Regular expression matching. Supports full regex syntax.

```hcl
{
  type  = "regex"
  field = "to"
  value = "^team-.*@yourdomain\\.com$"  # Matches team-*@yourdomain.com
}
```

## Matcher Fields

| Field | Description | Example |
|-------|-------------|---------|
| `to` | Recipient email address | `contact@yourdomain.com` |
| `from` | Sender email address | `user@example.com` |
| `subject` | Email subject line | `Order Confirmation` |

## Action Types

### Forward

Forward email to one or more destination addresses.

```hcl
actions = [
  {
    type  = "forward"
    value = ["admin@example.com", "backup@example.com"]
  }
]
```

### Drop

Reject/drop the email.

```hcl
actions = [
  {
    type = "drop"
  }
]
```

### Worker

Process with a Cloudflare Worker (advanced).

```hcl
actions = [
  {
    type  = "worker"
    value = ["email-processor-worker"]
  }
]
```

## Priority System

Rules are evaluated in order of priority (lower numbers first). The **first matching rule** is applied.

```hcl
rules = [
  # Priority 0 - checked first
  {
    name     = "Specific contact"
    priority = 0
    # ...
  },
  # Priority 10 - checked second
  {
    name     = "Support emails"
    priority = 10
    # ...
  },
  # Priority 100 - checked last (catch-all)
  {
    name     = "Catch all"
    priority = 100
    # ...
  }
]
```

!!! tip "Priority Best Practice"
    - Use priority 0-10 for specific rules
    - Use priority 100+ for catch-all rules
    - Leave gaps for easier insertion later

## Important Notes

!!! warning "Email Verification Required"
    All destination addresses must be verified by Cloudflare before they can receive forwarded emails. Cloudflare automatically sends verification emails when addresses are added.

!!! info "MX Records"
    When email routing is enabled, Cloudflare automatically manages MX records for your domain. Any existing MX records will be overridden.

!!! tip "Testing"
    After setting up rules, test by sending emails to verify routing works as expected.

!!! warning "Limitations"
    - Free plan: Up to 200 destination addresses
    - Email size limit: 25 MB
    - Attachments are preserved when forwarding

## DNS Requirements

Email routing requires your domain to use Cloudflare nameservers. The module will automatically configure the necessary MX records.

## Verification Process

1. Add destination addresses to the configuration
2. Apply Terraform configuration
3. Check the email inbox for verification emails from Cloudflare
4. Click the verification link in each email
5. Addresses are now ready to receive forwarded emails

## Troubleshooting

### Emails Not Being Forwarded

1. Check that destination addresses are verified
2. Verify MX records are configured correctly
3. Check rule priorities and matcher patterns
4. Review Cloudflare dashboard for email routing logs

### Verification Email Not Received

1. Check spam/junk folder
2. Ensure email address is correct
3. Try resending from Cloudflare dashboard

## Related

- [DNS Module](dns.md) - Manage DNS records
- [Complete Setup Example](../examples/complete-setup.md)
- [Cloudflare Email Routing Documentation](https://developers.cloudflare.com/email-routing/)
