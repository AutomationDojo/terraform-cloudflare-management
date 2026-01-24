resource "cloudflare_r2_bucket" "buckets" {
  for_each = { for idx, bucket in var.buckets : bucket.name => bucket }

  account_id = var.account_id
  name       = each.value.name
  location   = each.value.location
  jurisdiction = each.value.jurisdiction
  storage_class = each.value.storage_class

  lifecycle {
    create_before_destroy = true
  }
}
