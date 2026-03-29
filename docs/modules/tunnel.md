# Tunnel Module

The Tunnel module enables you to create and manage Cloudflare Tunnels for secure connectivity between your origin servers and Cloudflare's edge network without exposing your origin IP addresses.

## Features

- **Secure Connectivity**: Expose services without opening firewall ports
- **Automatic Secret Generation**: Tunnel secrets are generated securely
- **Ingress Rules**: Route traffic to different services based on hostname/path
- **Private Networks**: Connect private IP ranges for WARP client access
- **Credentials Output**: Ready-to-use credentials for cloudflared daemon
- **File Output Support**: Automatically save credentials to plaintext or SOPS-encrypted files

## Basic Usage

```hcl
module "tunnel" {
  source = "AutomationDojo/management/cloudflare//modules/tunnel"
  version = "2.3.0"

  account_id = var.cloudflare_account_id

  tunnels = {
    web-tunnel = {
      name = "web-app-tunnel"
      ingress_rules = [
        {
          hostname = "app.example.com"
          service  = "http://localhost:8080"
        },
        {
          # Catch-all rule (required)
          service = "http_status:404"
        }
      ]
    }
  }
}
```

## Advanced Examples

### Multiple Services on One Tunnel

```hcl
module "tunnel" {
  source = "AutomationDojo/management/cloudflare//modules/tunnel"
  version = "2.3.0"

  account_id = var.cloudflare_account_id

  tunnels = {
    multi-service = {
      name = "multi-service-tunnel"
      ingress_rules = [
        {
          hostname = "app.example.com"
          service  = "http://localhost:3000"
        },
        {
          hostname = "api.example.com"
          service  = "http://localhost:8080"
        },
        {
          hostname = "grafana.example.com"
          service  = "http://localhost:3001"
        },
        {
          hostname = "ssh.example.com"
          service  = "ssh://localhost:22"
        },
        {
          service = "http_status:404"
        }
      ]
    }
  }
}
```

### Path-Based Routing

```hcl
module "tunnel" {
  source = "AutomationDojo/management/cloudflare//modules/tunnel"
  version = "2.3.0"

  account_id = var.cloudflare_account_id

  tunnels = {
    api-gateway = {
      name = "api-gateway-tunnel"
      ingress_rules = [
        {
          hostname = "api.example.com"
          path     = "/v1/*"
          service  = "http://api-v1:8080"
        },
        {
          hostname = "api.example.com"
          path     = "/v2/*"
          service  = "http://api-v2:8080"
        },
        {
          hostname = "api.example.com"
          service  = "http://api-v1:8080"  # Default for api.example.com
        },
        {
          service = "http_status:404"
        }
      ]
    }
  }
}
```

### Private Network Access (WARP)

```hcl
module "tunnel" {
  source = "AutomationDojo/management/cloudflare//modules/tunnel"
  version = "2.3.0"

  account_id = var.cloudflare_account_id

  tunnels = {
    private-access = {
      name = "private-network-tunnel"
      private_networks = [
        {
          network = "10.0.0.0/8"
          comment = "AWS VPC"
        },
        {
          network = "172.16.0.0/12"
          comment = "GCP VPC"
        },
        {
          network = "192.168.0.0/16"
          comment = "Office network"
        }
      ]
    }
  }
}
```

### HTTPS Backend with Custom Origin Settings

```hcl
module "tunnel" {
  source = "AutomationDojo/management/cloudflare//modules/tunnel"
  version = "2.3.0"

  account_id = var.cloudflare_account_id

  tunnels = {
    secure-backend = {
      name = "secure-backend-tunnel"
      ingress_rules = [
        {
          hostname = "internal.example.com"
          service  = "https://internal-server:443"
          origin_request = {
            origin_server_name = "internal-server.local"
            no_tls_verify      = false
            connect_timeout    = "30s"
            http2_origin       = true
          }
        },
        {
          hostname = "legacy.example.com"
          service  = "https://legacy-server:443"
          origin_request = {
            no_tls_verify    = true  # For self-signed certs
            http_host_header = "legacy-app"
          }
        },
        {
          service = "http_status:404"
        }
      ]
    }
  }
}
```

### Combined Ingress and Private Networks

```hcl
module "tunnel" {
  source = "AutomationDojo/management/cloudflare//modules/tunnel"
  version = "2.3.0"

  account_id = var.cloudflare_account_id

  tunnels = {
    hybrid = {
      name = "hybrid-tunnel"

      # Public-facing services
      ingress_rules = [
        {
          hostname = "app.example.com"
          service  = "http://localhost:8080"
        },
        {
          service = "http_status:404"
        }
      ]

      # Private network access via WARP
      private_networks = [
        {
          network = "10.0.0.0/8"
          comment = "Internal network for WARP users"
        }
      ]
    }
  }
}
```

### Saving Credentials with SOPS Encryption

```hcl
module "tunnel" {
  source = "AutomationDojo/management/cloudflare//modules/tunnel"
  version = "2.3.0"

  account_id = var.cloudflare_account_id

  tunnels = {
    homelab = {
      name = "homelab-tunnel"
      ingress_rules = [
        {
          hostname = "ts.homelab.sts.ruicoelho.dev"
          service  = "http://localhost:8080"
        },
        {
          service = "http_status:404"
        }
      ]
    }
    production = {
      name = "production-tunnel"
      ingress_rules = [
        {
          hostname = "app.production.example.com"
          service  = "http://localhost:3000"
        },
        {
          service = "http_status:404"
        }
      ]
    }
  }

  # Save credentials to SOPS-encrypted files
  # Creates: tunnel-homelab.encrypted.json and tunnel-production.encrypted.json
  output_file_path   = "${path.root}/../../common/secrets/tunnel-{tunnel_key}.encrypted.json"
  output_file_format = "sops"
  sops_config_file   = "${path.root}/../../.sops.yaml"
}
```

## Inputs

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| `account_id` | Cloudflare account ID | `string` | Yes | - |
| `tunnels` | Map of tunnels to create | `map(object)` | No | `{}` |
| `output_file_path` | Path to save tunnel credentials file(s). Use `{tunnel_key}` placeholder to create one file per tunnel. If not set, credentials are only available via outputs. | `string` | No | `null` |
| `output_file_format` | Format for output file: `plaintext` for unencrypted JSON, `sops` for SOPS-encrypted JSON. Requires `output_file_path` to be set. | `string` | No | `"plaintext"` |
| `sops_config_file` | Path to SOPS configuration file (.sops.yaml). Only used when `output_file_format` is `sops`. If not set, SOPS will search for it automatically. | `string` | No | `null` |

### Tunnel Object

| Field | Description | Type | Required | Default |
|-------|-------------|------|----------|---------|
| `name` | Tunnel name | `string` | Yes | - |
| `config_src` | Configuration source (`cloudflare` or `local`) | `string` | No | `"cloudflare"` |
| `ingress_rules` | List of ingress rules | `list(object)` | No | `[]` |
| `private_networks` | List of private network routes | `list(object)` | No | `[]` |

### Ingress Rule Object

| Field | Description | Type | Required |
|-------|-------------|------|----------|
| `hostname` | Public hostname to match | `string` | No |
| `path` | URL path to match | `string` | No |
| `service` | Backend service URL | `string` | Yes |
| `origin_request` | Origin connection settings | `object` | No |

### Origin Request Object

| Field | Description | Type | Default |
|-------|-------------|------|---------|
| `connect_timeout` | TCP connection timeout | `string` | - |
| `tls_timeout` | TLS handshake timeout | `string` | - |
| `tcp_keep_alive` | TCP keepalive timeout | `string` | - |
| `no_tls_verify` | Skip TLS certificate verification | `bool` | `false` |
| `origin_server_name` | Expected server certificate hostname | `string` | - |
| `http_host_header` | HTTP Host header to send | `string` | - |
| `http2_origin` | Use HTTP/2 to connect to origin | `bool` | `false` |

### Private Network Object

| Field | Description | Type | Required |
|-------|-------------|------|----------|
| `network` | CIDR range (e.g., `10.0.0.0/8`) | `string` | Yes |
| `comment` | Description of the network | `string` | No |
| `virtual_network_id` | Virtual network ID | `string` | No |

## Outputs

| Name | Description |
|------|-------------|
| `tunnels` | Map of created tunnels with id, name, status |
| `tunnel_tokens` | Tunnel tokens for cloudflared (sensitive) |
| `tunnel_secrets` | Tunnel secrets (sensitive) |
| `tunnel_creds_json` | Full credentials JSON for cloudflared config (sensitive) |
| `routes` | Map of private network routes |

## Saving Credentials to Files

The module supports automatically saving tunnel credentials to files, either as plaintext JSON or encrypted with SOPS.

### Plaintext File Output

```hcl
module "tunnel" {
  source = "AutomationDojo/management/cloudflare//modules/tunnel"
  version = "2.3.0"

  account_id = var.cloudflare_account_id
  tunnels    = var.tunnels

  # Save credentials to plaintext file
  output_file_path   = "~/.cloudflared/credentials.json"
  output_file_format = "plaintext"
}
```

### SOPS Encrypted File Output

For better security, you can save credentials encrypted with SOPS:

```hcl
module "tunnel" {
  source = "AutomationDojo/management/cloudflare//modules/tunnel"
  version = "2.3.0"

  account_id = var.cloudflare_account_id
  tunnels    = var.tunnels

  # Save credentials to SOPS-encrypted file
  output_file_path   = "${path.root}/../../common/secrets/tunnel-{tunnel_key}.encrypted.json"
  output_file_format = "sops"
  sops_config_file   = "${path.root}/../../.sops.yaml"
}
```

**Key Features:**
- Use `{tunnel_key}` placeholder in `output_file_path` to create one file per tunnel
- Each tunnel gets its own credentials file (e.g., `tunnel-homelab.encrypted.json`)
- Files are automatically created with proper permissions (0600)
- SOPS encryption requires SOPS to be installed and configured

**Example with multiple tunnels:**
```hcl
module "tunnel" {
  source = "AutomationDojo/management/cloudflare//modules/tunnel"
  version = "2.3.0"

  account_id = var.cloudflare_account_id
  
  tunnels = {
    homelab = { ... }
    production = { ... }
  }

  # Creates: tunnel-homelab.encrypted.json and tunnel-production.encrypted.json
  output_file_path   = "secrets/tunnel-{tunnel_key}.encrypted.json"
  output_file_format = "sops"
  sops_config_file   = ".sops.yaml"
}
```

## Running cloudflared

After creating the tunnel, you need to run `cloudflared` on your origin server.

### Using Docker

```bash
# Get the tunnel token
TUNNEL_TOKEN=$(terraform output -raw tunnel_creds_json | jq -r '.TunnelID')

# Run cloudflared
docker run -d \
  --name cloudflared \
  --restart unless-stopped \
  cloudflare/cloudflared:latest \
  tunnel run --token $TUNNEL_TOKEN
```

### Using Credentials File (from Terraform Output)

```bash
# Export credentials
terraform output -raw tunnel_creds_json > ~/.cloudflared/credentials.json

# Create config.yml
cat > ~/.cloudflared/config.yml << EOF
tunnel: $(terraform output -json tunnels | jq -r '.["my-tunnel"].id')
credentials-file: /home/user/.cloudflared/credentials.json
EOF

# Run cloudflared
cloudflared tunnel run
```

### Using SOPS-Encrypted Credentials File

If you used SOPS encryption, decrypt the file first:

```bash
# Decrypt credentials file
sops -d secrets/tunnel-homelab.encrypted.json > ~/.cloudflared/credentials.json

# Or use sops exec-env to run cloudflared with decrypted credentials
sops exec-env secrets/tunnel-homelab.encrypted.json 'cloudflared tunnel run --credentials-file /dev/stdin' < <(sops -d secrets/tunnel-homelab.encrypted.json)
```

### Systemd Service

```ini
[Unit]
Description=Cloudflare Tunnel
After=network.target

[Service]
Type=simple
User=cloudflared
ExecStart=/usr/local/bin/cloudflared tunnel run
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
```

## Service URL Formats

| Protocol | Format | Example |
|----------|--------|---------|
| HTTP | `http://host:port` | `http://localhost:8080` |
| HTTPS | `https://host:port` | `https://localhost:443` |
| SSH | `ssh://host:port` | `ssh://localhost:22` |
| RDP | `rdp://host:port` | `rdp://localhost:3389` |
| TCP | `tcp://host:port` | `tcp://localhost:5432` |
| Unix Socket | `unix:/path/to/socket` | `unix:/var/run/app.sock` |
| HTTP Status | `http_status:code` | `http_status:404` |

## Important Notes

!!! warning "Catch-All Rule Required"
    Ingress rules must end with a catch-all rule (no hostname) like `service = "http_status:404"`. This handles unmatched requests.

!!! info "DNS Records"
    You still need to create DNS records pointing to your tunnel. Use the DNS module or create CNAME records pointing to `<tunnel-id>.cfargotunnel.com`.

!!! tip "Private Networks"
    Private network routes require the WARP client on user devices. Configure Device Enrollment in the Zero Trust dashboard.

!!! warning "Tunnel Secrets"
    The tunnel secret is generated automatically and stored in Terraform state. Ensure your state is stored securely. When using `output_file_format = "sops"`, credentials are encrypted before being written to disk, providing an additional layer of security.

## DNS Integration

To expose services publicly, create DNS records:

```hcl
module "dns" {
  source = "AutomationDojo/management/cloudflare//modules/dns"
  version = "2.3.0"

  zone_id = var.cloudflare_zone_id

  records = [
    {
      name    = "app"
      type    = "CNAME"
      value   = "${module.tunnel.tunnels["my-tunnel"].id}.cfargotunnel.com"
      proxied = true
    }
  ]
}
```

## Related

- [DNS Module](dns.md) - Create DNS records for your tunnel
- [Cloudflare Tunnel Documentation](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/)
- [Zero Trust Documentation](https://developers.cloudflare.com/cloudflare-one/)
