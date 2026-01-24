# Note: Email routing settings must be enabled manually in Cloudflare UI first
# or ensure your API token has the necessary permissions

# Create destination email addresses
resource "cloudflare_email_routing_address" "addresses" {
  for_each = var.email_routing.enabled ? {
    for idx, addr in var.email_routing.addresses : addr.email => addr
  } : {}

  account_id = var.account_id
  email      = each.value.email
}

# Create email routing rules
resource "cloudflare_email_routing_rule" "rules" {
  for_each = var.email_routing.enabled ? {
    for idx, rule in var.email_routing.rules : rule.name => rule
  } : {}

  zone_id  = var.zone_id
  name     = each.value.name
  enabled  = each.value.enabled
  priority = each.value.priority

  matchers = [
    for m in each.value.matchers : {
      type  = m.type
      field = m.field
      value = m.value
    }
  ]

  actions = [
    for a in each.value.actions : {
      type  = a.type
      value = a.value
    }
  ]

  depends_on = [
    cloudflare_email_routing_address.addresses
  ]
}
