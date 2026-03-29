output "projects" {
  description = "Map of all Cloudflare Pages projects"
  value = {
    for k, v in cloudflare_pages_project.projects : k => {
      id        = v.id
      name      = v.name
      subdomain = v.subdomain
      domains   = v.domains
    }
  }
}

output "custom_domains" {
  description = "Map of custom domains configured"
  value = {
    for k, v in cloudflare_pages_domain.domains : k => {
      domain = v.name
      url    = "https://${v.name}"
    }
  }
}

output "default_urls" {
  description = "Map of default pages.dev URLs"
  value = {
    for k, v in cloudflare_pages_project.projects : k => "https://${v.subdomain}"
  }
}
