# Generate random secret for each tunnel
resource "random_id" "tunnel_secret" {
  for_each    = var.tunnels
  byte_length = 32
}

# Create Cloudflare Tunnels
resource "cloudflare_zero_trust_tunnel_cloudflared" "tunnels" {
  for_each = var.tunnels

  account_id    = var.account_id
  name          = each.value.name
  config_src    = each.value.config_src
  tunnel_secret = random_id.tunnel_secret[each.key].b64_std
}

# Get tunnel tokens (required for running cloudflared with --token flag)
data "cloudflare_zero_trust_tunnel_cloudflared_token" "tokens" {
  for_each = cloudflare_zero_trust_tunnel_cloudflared.tunnels

  account_id = var.account_id
  tunnel_id  = each.value.id
}

# Configure tunnel ingress rules (only for cloudflare-managed tunnels with ingress rules)
resource "cloudflare_zero_trust_tunnel_cloudflared_config" "configs" {
  for_each = {
    for k, v in var.tunnels : k => v
    if v.config_src == "cloudflare" && length(v.ingress_rules) > 0
  }

  account_id = var.account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.tunnels[each.key].id
  source     = "cloudflare"

  config = {
    ingress = [
      for rule in each.value.ingress_rules : {
        hostname = rule.hostname
        path     = rule.path
        service  = rule.service
        origin_request = rule.origin_request != null ? {
          connect_timeout          = rule.origin_request.connect_timeout
          tls_timeout              = rule.origin_request.tls_timeout
          tcp_keep_alive           = rule.origin_request.tcp_keep_alive
          no_happy_eyeballs        = rule.origin_request.no_happy_eyeballs
          keep_alive_connections   = rule.origin_request.keep_alive_connections
          keep_alive_timeout       = rule.origin_request.keep_alive_timeout
          http_host_header         = rule.origin_request.http_host_header
          origin_server_name       = rule.origin_request.origin_server_name
          ca_pool                  = rule.origin_request.ca_pool
          no_tls_verify            = rule.origin_request.no_tls_verify
          disable_chunked_encoding = rule.origin_request.disable_chunked_encoding
          http2_origin             = rule.origin_request.http2_origin
          proxy_type               = rule.origin_request.proxy_type
          access = rule.origin_request.access != null ? {
            aud_tag   = rule.origin_request.access.aud_tag
            team_name = rule.origin_request.access.team_name
            required  = rule.origin_request.access.required
          } : null
        } : null
      }
    ]
  }
}

# Flatten private networks for route creation
locals {
  private_network_routes = flatten([
    for tunnel_key, tunnel in var.tunnels : [
      for idx, network in tunnel.private_networks : {
        key                = "${tunnel_key}-${idx}"
        tunnel_key         = tunnel_key
        network            = network.network
        comment            = network.comment
        virtual_network_id = network.virtual_network_id
      }
    ]
  ])
}

# Create private network routes
resource "cloudflare_zero_trust_tunnel_cloudflared_route" "routes" {
  for_each = { for route in local.private_network_routes : route.key => route }

  account_id         = var.account_id
  tunnel_id          = cloudflare_zero_trust_tunnel_cloudflared.tunnels[each.value.tunnel_key].id
  network            = each.value.network
  comment            = each.value.comment
  virtual_network_id = each.value.virtual_network_id
}



# Write credentials to plaintext file (one file per tunnel)
resource "local_file" "tunnel_credentials" {
  for_each = var.output_file_path != null && var.output_file_format == "plaintext" ? local.tunnel_file_paths : {}

  filename        = each.value
  content         = local.tunnel_credentials_json[each.key]
  file_permission = "0600"

  lifecycle {
    create_before_destroy = true
  }
}

# Write credentials to SOPS-encrypted file (one file per tunnel)
resource "null_resource" "tunnel_credentials_sops" {
  for_each = var.output_file_path != null && var.output_file_format == "sops" ? local.tunnel_file_paths : {}

  triggers = {
    credentials_json = local.tunnel_credentials_json[each.key]
    file_path        = each.value
    tunnel_key       = each.key
  }

  provisioner "local-exec" {
    command = <<-EOT
      script_path="${path.module}/scripts/encrypt-sops.sh"
      output_file="${each.value}"
      %{ if var.sops_config_file != null ~}
      sops_config="${var.sops_config_file}"
      cat <<'JSONEOF' | "$script_path" "$output_file" "$sops_config"
${local.tunnel_credentials_json[each.key]}
JSONEOF
      %{ else ~}
      cat <<'JSONEOF' | "$script_path" "$output_file"
${local.tunnel_credentials_json[each.key]}
JSONEOF
      %{ endif ~}
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      rm -f "${self.triggers.file_path}"
    EOT
    on_failure = continue
  }
}

# Write tunnel tokens to plaintext file (one file per tunnel)
resource "local_file" "tunnel_tokens" {
  for_each = var.output_token_file_path != null && var.output_file_format == "plaintext" ? local.tunnel_token_file_paths : {}

  filename        = each.value
  content         = local.tunnel_token_json[each.key]
  file_permission = "0600"

  lifecycle {
    create_before_destroy = true
  }
}

# Write tunnel tokens to SOPS-encrypted file (one file per tunnel)
resource "null_resource" "tunnel_tokens_sops" {
  for_each = var.output_token_file_path != null && var.output_file_format == "sops" ? local.tunnel_token_file_paths : {}

  triggers = {
    token_json = local.tunnel_token_json[each.key]
    file_path  = each.value
    tunnel_key = each.key
  }

  provisioner "local-exec" {
    command = <<-EOT
      script_path="${path.module}/scripts/encrypt-sops.sh"
      output_file="${each.value}"
      %{ if var.sops_config_file != null ~}
      sops_config="${var.sops_config_file}"
      cat <<'JSONEOF' | "$script_path" "$output_file" "$sops_config"
${local.tunnel_token_json[each.key]}
JSONEOF
      %{ else ~}
      cat <<'JSONEOF' | "$script_path" "$output_file"
${local.tunnel_token_json[each.key]}
JSONEOF
      %{ endif ~}
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      rm -f "${self.triggers.file_path}"
    EOT
    on_failure = continue
  }
}
