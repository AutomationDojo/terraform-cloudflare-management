locals {
  r2_custom_domains = flatten([
    for bucket in var.buckets : [
      for domain in bucket.custom_domains : {
        key          = "${bucket.name}-${domain.domain}"
        bucket_name  = bucket.name
        jurisdiction = bucket.jurisdiction
        domain       = domain.domain
        zone_id      = domain.zone_id
        enabled      = domain.enabled
        min_tls      = domain.min_tls
      }
    ]
  ])
}
