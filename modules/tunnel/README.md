# Cloudflare Tunnel Module

Terraform module for creating and managing Cloudflare Tunnels (formerly Argo Tunnels) for secure connectivity to your origin servers.

## Features

- Create Cloudflare Tunnels with automatic secret generation
- Configure ingress rules for routing traffic to services
- Set up private network routes for WARP client access
- Support for both cloudflare-managed and locally-managed tunnels
- Output credentials for cloudflared daemon configuration

## Examples

### Basic Tunnel with Ingress Rules

```hcl
module "tunnel" {
  source = "AutomationDojo/management/cloudflare//modules/tunnel"
  version = "2.3.0"

  account_id = var.cloudflare_account_id

  tunnels = {
    my-tunnel = {
      name = "my-app-tunnel"
      ingress_rules = [
        {
          hostname = "app.example.com"
          service  = "http://localhost:8080"
        },
        {
          hostname = "api.example.com"
          path     = "/v1/*"
          service  = "http://localhost:3000"
        },
        {
          # Catch-all rule (required as last rule)
          service = "http_status:404"
        }
      ]
    }
  }
}
```

### Tunnel with Private Network Routes

```hcl
module "tunnel" {
  source = "AutomationDojo/management/cloudflare//modules/tunnel"
  version = "2.3.0"

  account_id = var.cloudflare_account_id

  tunnels = {
    private-network = {
      name = "private-network-tunnel"
      private_networks = [
        {
          network = "10.0.0.0/8"
          comment = "Internal network"
        },
        {
          network = "192.168.1.0/24"
          comment = "Office network"
        }
      ]
    }
  }
}
```

### Advanced Configuration with Origin Settings

```hcl
module "tunnel" {
  source = "AutomationDojo/management/cloudflare//modules/tunnel"
  version = "2.3.0"

  account_id = var.cloudflare_account_id

  tunnels = {
    advanced = {
      name = "advanced-tunnel"
      ingress_rules = [
        {
          hostname = "internal.example.com"
          service  = "https://internal-server:443"
          origin_request = {
            no_tls_verify      = true
            connect_timeout    = "30s"
            http_host_header   = "internal-server"
            origin_server_name = "internal-server"
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

## Running cloudflared

After creating a tunnel, you need to run the cloudflared daemon. There are several ways to get the credentials:

### Option 1: Using Terraform Outputs

Get the credentials from Terraform outputs:

```hcl
output "tunnel_creds" {
  value     = module.tunnel.tunnel_creds_json["my-tunnel"]
  sensitive = true
}
```

Then run cloudflared:

```bash
# Save credentials to file
terraform output -raw tunnel_creds > ~/.cloudflared/credentials.json

# Run cloudflared
cloudflared tunnel --config ~/.cloudflared/config.yml run
```

### Option 2: Automatic File Output (Plaintext)

The module can automatically write credentials to a file:

```hcl
module "tunnel" {
  source = "AutomationDojo/management/cloudflare//modules/tunnel"
  version = "2.3.0"

  account_id = var.cloudflare_account_id

  tunnels = {
    my-tunnel = {
      name = "my-app-tunnel"
      ingress_rules = [
        {
          hostname = "app.example.com"
          service  = "http://localhost:8080"
        },
        {
          service = "http_status:404"
        }
      ]
    }
  }

  # Automatically save credentials to plaintext file
  output_file_path   = "~/.cloudflared/credentials.json"
  output_file_format = "plaintext"
}
```

The credentials file will be created automatically with proper permissions (0600).

### Option 3: Automatic File Output (SOPS Encrypted)

For better security, you can save credentials encrypted with SOPS:

```hcl
module "tunnel" {
  source = "AutomationDojo/management/cloudflare//modules/tunnel"
  version = "2.3.0"

  account_id = var.cloudflare_account_id

  tunnels = {
    my-tunnel = {
      name = "my-app-tunnel"
      ingress_rules = [
        {
          hostname = "app.example.com"
          service  = "http://localhost:8080"
        },
        {
          service = "http_status:404"
        }
      ]
    }
  }

  # Automatically save credentials to SOPS-encrypted file
  # Use {tunnel_key} placeholder to create one file per tunnel
  output_file_path   = "secrets/tunnel-{tunnel_key}.encrypted.json"
  output_file_format = "sops"
  sops_config_file   = ".sops.yaml"  # Optional: specify SOPS config file
}
```

**Key Features:**
- Use `{tunnel_key}` placeholder in `output_file_path` to create one file per tunnel
- Each tunnel gets its own credentials file (e.g., `tunnel-homelab.encrypted.json`)
- Files are automatically created with proper permissions (0600)
- SOPS encryption requires SOPS to be installed and configured

**Note:** SOPS must be installed and configured (with encryption keys) for this to work. The file will be encrypted using your SOPS configuration. If `sops_config_file` is not provided, SOPS will automatically search for `.sops.yaml` in parent directories.

### Using the Tunnel Token Directly

Alternatively, you can use the tunnel token directly:

```bash
cloudflared tunnel run --token <tunnel_token>
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_cloudflare"></a> [cloudflare](#requirement\_cloudflare) | ~> 5.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | ~> 2.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_cloudflare"></a> [cloudflare](#provider\_cloudflare) | ~> 5.0 |
| <a name="provider_local"></a> [local](#provider\_local) | ~> 2.0 |
| <a name="provider_null"></a> [null](#provider\_null) | ~> 3.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.0 |

## Resources

| Name | Type |
|------|------|
| [cloudflare_zero_trust_tunnel_cloudflared.tunnels](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/zero_trust_tunnel_cloudflared) | resource |
| [cloudflare_zero_trust_tunnel_cloudflared_config.configs](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/zero_trust_tunnel_cloudflared_config) | resource |
| [cloudflare_zero_trust_tunnel_cloudflared_route.routes](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/zero_trust_tunnel_cloudflared_route) | resource |
| [local_file.tunnel_credentials](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.tunnel_tokens](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [null_resource.tunnel_credentials_sops](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.tunnel_tokens_sops](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_id.tunnel_secret](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | Cloudflare account ID | `string` | n/a | yes |
| <a name="input_output_file_format"></a> [output\_file\_format](#input\_output\_file\_format) | Format for output file: 'plaintext' for unencrypted JSON, 'sops' for SOPS-encrypted JSON. Requires output\_file\_path to be set. | `string` | `"plaintext"` | no |
| <a name="input_output_file_path"></a> [output\_file\_path](#input\_output\_file\_path) | Path to save tunnel credentials file(s). If set, credentials will be written to file(s). Use {tunnel\_key} placeholder to create one file per tunnel (e.g., 'credentials/{tunnel\_key}.json'). If no placeholder, creates a single file with all tunnels. Use with output\_file\_format to choose between plaintext or SOPS encryption. | `string` | `null` | no |
| <a name="input_output_token_file_path"></a> [output\_token\_file\_path](#input\_output\_token\_file\_path) | Path to save tunnel token file(s). Use {tunnel\_key} placeholder to create one file per tunnel. If set, tokens will be written to file(s) using the same format as output\_file\_format. If not set, tokens are only available via outputs. | `string` | `null` | no |
| <a name="input_sops_config_file"></a> [sops\_config\_file](#input\_sops\_config\_file) | Path to SOPS configuration file (.sops.yaml). If not set, SOPS will search for it automatically. Only used when output\_file\_format is 'sops'. | `string` | `null` | no |
| <a name="input_tunnels"></a> [tunnels](#input\_tunnels) | Map of Cloudflare Tunnels to create | <pre>map(object({<br/>    name       = string<br/>    config_src = optional(string, "cloudflare")<br/>    ingress_rules = optional(list(object({<br/>      hostname = optional(string)<br/>      path     = optional(string)<br/>      service  = string<br/>      origin_request = optional(object({<br/>        connect_timeout          = optional(string)<br/>        tls_timeout              = optional(string)<br/>        tcp_keep_alive           = optional(string)<br/>        no_happy_eyeballs        = optional(bool)<br/>        keep_alive_connections   = optional(number)<br/>        keep_alive_timeout       = optional(string)<br/>        http_host_header         = optional(string)<br/>        origin_server_name       = optional(string)<br/>        ca_pool                  = optional(string)<br/>        no_tls_verify            = optional(bool)<br/>        disable_chunked_encoding = optional(bool)<br/>        http2_origin             = optional(bool)<br/>        proxy_type               = optional(string)<br/>        access = optional(object({<br/>          aud_tag   = list(string)<br/>          team_name = string<br/>          required  = optional(bool, true)<br/>        }))<br/>      }))<br/>    })), [])<br/>    private_networks = optional(list(object({<br/>      network            = string<br/>      comment            = optional(string)<br/>      virtual_network_id = optional(string)<br/>    })), [])<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_routes"></a> [routes](#output\_routes) | Map of private network routes created |
| <a name="output_tunnel_creds_json"></a> [tunnel\_creds\_json](#output\_tunnel\_creds\_json) | Map of tunnel credentials in JSON format for cloudflared config |
| <a name="output_tunnel_secrets"></a> [tunnel\_secrets](#output\_tunnel\_secrets) | Map of tunnel secrets (sensitive) |
| <a name="output_tunnel_tokens"></a> [tunnel\_tokens](#output\_tunnel\_tokens) | Map of tunnel tokens for running cloudflared with --token flag (sensitive) |
| <a name="output_tunnels"></a> [tunnels](#output\_tunnels) | Map of created tunnels with their details |
<!-- END_TF_DOCS -->
