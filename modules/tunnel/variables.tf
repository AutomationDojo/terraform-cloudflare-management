variable "account_id" {
  description = "Cloudflare account ID"
  type        = string
}

variable "tunnels" {
  description = "Map of Cloudflare Tunnels to create"
  type = map(object({
    name       = string
    config_src = optional(string, "cloudflare")
    ingress_rules = optional(list(object({
      hostname = optional(string)
      path     = optional(string)
      service  = string
      origin_request = optional(object({
        connect_timeout          = optional(string)
        tls_timeout              = optional(string)
        tcp_keep_alive           = optional(string)
        no_happy_eyeballs        = optional(bool)
        keep_alive_connections   = optional(number)
        keep_alive_timeout       = optional(string)
        http_host_header         = optional(string)
        origin_server_name       = optional(string)
        ca_pool                  = optional(string)
        no_tls_verify            = optional(bool)
        disable_chunked_encoding = optional(bool)
        http2_origin             = optional(bool)
        proxy_type               = optional(string)
        access = optional(object({
          aud_tag   = list(string)
          team_name = string
          required  = optional(bool, true)
        }))
      }))
    })), [])
    private_networks = optional(list(object({
      network            = string
      comment            = optional(string)
      virtual_network_id = optional(string)
    })), [])
  }))
  default = {}
}

variable "output_file_path" {
  description = "Path to save tunnel credentials file(s). If set, credentials will be written to file(s). Use {tunnel_key} placeholder to create one file per tunnel (e.g., 'credentials/{tunnel_key}.json'). If no placeholder, creates a single file with all tunnels. Use with output_file_format to choose between plaintext or SOPS encryption."
  type        = string
  default     = null
}

variable "output_file_format" {
  description = "Format for output file: 'plaintext' for unencrypted JSON, 'sops' for SOPS-encrypted JSON. Requires output_file_path to be set."
  type        = string
  default     = "plaintext"
  validation {
    condition     = contains(["plaintext", "sops"], var.output_file_format)
    error_message = "output_file_format must be either 'plaintext' or 'sops'."
  }
}

variable "sops_config_file" {
  description = "Path to SOPS configuration file (.sops.yaml). If not set, SOPS will search for it automatically. Only used when output_file_format is 'sops'."
  type        = string
  default     = null
}

variable "output_token_file_path" {
  description = "Path to save tunnel token file(s). Use {tunnel_key} placeholder to create one file per tunnel. If set, tokens will be written to file(s) using the same format as output_file_format. If not set, tokens are only available via outputs."
  type        = string
  default     = null
}
