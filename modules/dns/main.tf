resource "cloudflare_dns_record" "records" {
  for_each = { for idx, record in var.records : "${record.type}-${record.name}-${idx}" => record }

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
