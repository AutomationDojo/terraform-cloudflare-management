output "buckets" {
  description = "Map of R2 buckets created"
  value = {
    for k, v in cloudflare_r2_bucket.buckets : k => {
      id       = v.id
      name     = v.name
      location = v.location
    }
  }
}

output "bucket_cors" {
  description = "Map of R2 bucket CORS configurations"
  value = {
    for k, v in cloudflare_r2_bucket_cors.cors : k => {
      bucket_name = v.bucket_name
      rules       = v.rules
    }
  }
}

output "custom_domains" {
  description = "Map of R2 custom domain bindings"
  value = {
    for k, v in cloudflare_r2_custom_domain.domains : k => {
      bucket_name = v.bucket_name
      domain      = v.domain
      zone_id     = v.zone_id
      enabled     = v.enabled
      min_tls     = v.min_tls
    }
  }
}
