# Stable keys, so adding or removing a record never re-keys the others:
#   - record.key when set;
#   - otherwise "<type>-<name>" when that pair is unique in the list;
#   - otherwise "<type>-<name>-<value>" (e.g. several MX or TXT on the apex).
locals {
  base_keys = [for r in var.records : "${r.type}-${r.name}"]

  record_keys = [
    for r in var.records : (
      r.key != null ? r.key : (
        length([for b in local.base_keys : b if b == "${r.type}-${r.name}"]) > 1
        ? "${r.type}-${r.name}-${r.value}"
        : "${r.type}-${r.name}"
      )
    )
  ]

  records = { for i, r in var.records : local.record_keys[i] => r }
}

resource "cloudflare_dns_record" "records" {
  for_each = local.records

  zone_id = var.zone_id
  name = each.value.name == "@" ? data.cloudflare_zone.zone.name : (
    each.value.name == "" ? data.cloudflare_zone.zone.name : "${each.value.name}.${data.cloudflare_zone.zone.name}"
  )
  type     = each.value.type
  content  = each.value.value
  ttl      = each.value.ttl
  proxied  = each.value.proxied
  priority = each.value.priority

  lifecycle {
    create_before_destroy = true
  }
}
