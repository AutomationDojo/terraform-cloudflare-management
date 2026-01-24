output "records" {
  description = "Map of DNS records created"
  value = {
    for k, v in cloudflare_dns_record.records : k => {
      id      = v.id
      name    = v.name
      type    = v.type
      content = v.content
      proxied = v.proxied
      ttl     = v.ttl
    }
  }
}
