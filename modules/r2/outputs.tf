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
