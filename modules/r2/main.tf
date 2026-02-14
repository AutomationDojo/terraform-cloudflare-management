resource "cloudflare_r2_bucket" "buckets" {
  for_each = { for idx, bucket in var.buckets : bucket.name => bucket }

  account_id    = var.account_id
  name          = each.value.name
  location      = each.value.location
  jurisdiction  = each.value.jurisdiction
  storage_class = each.value.storage_class

  lifecycle {
    create_before_destroy = true
  }
}

resource "cloudflare_r2_bucket_cors" "cors" {
  for_each = {
    for k, v in var.buckets : v.name => v
    if length(v.cors_rules) > 0
  }

  account_id   = var.account_id
  bucket_name  = each.key
  jurisdiction = each.value.jurisdiction

  rules = [for rule in each.value.cors_rules : {
    id = rule.id
    allowed = {
      methods = rule.allowed_methods
      origins = rule.allowed_origins
      headers = rule.allowed_headers
    }
    expose_headers  = rule.expose_headers
    max_age_seconds = rule.max_age_seconds
  }]

  depends_on = [cloudflare_r2_bucket.buckets]
}

resource "cloudflare_r2_custom_domain" "domains" {
  for_each = { for d in local.r2_custom_domains : d.key => d }

  account_id   = var.account_id
  bucket_name  = each.value.bucket_name
  domain       = each.value.domain
  zone_id      = each.value.zone_id
  enabled      = each.value.enabled
  min_tls      = each.value.min_tls
  jurisdiction = each.value.jurisdiction

  depends_on = [cloudflare_r2_bucket.buckets]
}
