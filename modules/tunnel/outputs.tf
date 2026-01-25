output "tunnels" {
  description = "Map of created tunnels with their details"
  value = {
    for k, v in cloudflare_zero_trust_tunnel_cloudflared.tunnels : k => {
      id     = v.id
      name   = v.name
      status = v.status
    }
  }
}

output "tunnel_tokens" {
  description = "Map of tunnel tokens for running cloudflared with --token flag (sensitive)"
  value = {
    for k, v in data.cloudflare_zero_trust_tunnel_cloudflared_token.tokens : k => v.token
  }
  sensitive = true
}

output "tunnel_secrets" {
  description = "Map of tunnel secrets (sensitive)"
  value = {
    for k, v in random_id.tunnel_secret : k => v.b64_std
  }
  sensitive = true
}

output "tunnel_creds_json" {
  description = "Map of tunnel credentials in JSON format for cloudflared config"
  value = {
    for k, v in cloudflare_zero_trust_tunnel_cloudflared.tunnels : k => jsonencode({
      AccountTag   = var.account_id
      TunnelID     = v.id
      TunnelName   = v.name
      TunnelSecret = random_id.tunnel_secret[k].b64_std
    })
  }
  sensitive = true
}

output "routes" {
  description = "Map of private network routes created"
  value = {
    for k, v in cloudflare_zero_trust_tunnel_cloudflared_route.routes : k => {
      id      = v.id
      network = v.network
      comment = v.comment
    }
  }
}
