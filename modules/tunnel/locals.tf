# Prepare credentials data for file output (one JSON object per tunnel)
locals {
  tunnel_credentials_data = {
    for k, v in cloudflare_zero_trust_tunnel_cloudflared.tunnels : k => {
      AccountTag   = var.account_id
      TunnelID     = v.id
      TunnelName   = v.name
      TunnelSecret = random_id.tunnel_secret[k].b64_std
    }
  }
  # Individual tunnel credentials as JSON strings
  tunnel_credentials_json = {
    for k, v in local.tunnel_credentials_data : k => jsonencode(v)
  }
}

# Determine file path for each tunnel
locals {
  tunnel_file_paths = var.output_file_path != null ? {
    for k, v in cloudflare_zero_trust_tunnel_cloudflared.tunnels : k => replace(var.output_file_path, "{tunnel_key}", k)
  } : {}

  # Determine file path for tunnel tokens
  tunnel_token_file_paths = var.output_token_file_path != null ? {
    for k, v in cloudflare_zero_trust_tunnel_cloudflared.tunnels : k => replace(var.output_token_file_path, "{tunnel_key}", k)
  } : {}

  # Prepare token data as JSON (simple object with token)
  tunnel_token_json = {
    for k, v in data.cloudflare_zero_trust_tunnel_cloudflared_token.tokens : k => jsonencode({
      token = v.token
    })
  }
}