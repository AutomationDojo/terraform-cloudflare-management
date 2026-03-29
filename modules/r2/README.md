# Cloudflare R2 Module

Terraform module for managing Cloudflare R2 storage buckets.

## Features

- Create and manage R2 buckets
- Configurable bucket location
- Support for multiple buckets
- Auto location selection

## Usage

```hcl
module "r2" {
  source = "AutomationDojo/management/cloudflare//modules/r2"
  version = "2.3.0"

  account_id = var.cloudflare_account_id

  buckets = [
    {
      name          = "my-storage-bucket"
      location      = "eeur"
      jurisdiction  = "eu"
      storage_class = "Standard"
    },
    {
      name          = "us-data-bucket"
      location      = "wnam"
      jurisdiction  = "us"
      storage_class = "Standard"
    }
  ]
}
```

<!-- BEGIN_TF_DOCS -->
## Usage

```hcl
module "example" {
  source  = "AutomationDojo/management/cloudflare"
  version = "2.3.0"

  account_id = var.account_id

  buckets    = var.buckets # optional
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | `>= 1.0` |
| cloudflare | `~> 5.0` |

## Providers

| Name | Version |
|------|---------|
| cloudflare | `5.17.0` |

## Resources

| Name | Type |
|------|------|
| [cloudflare_r2_bucket.buckets](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/r2_bucket) | resource |
| [cloudflare_r2_bucket_cors.cors](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/r2_bucket_cors) | resource |
| [cloudflare_r2_custom_domain.domains](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/r2_custom_domain) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| account_id | Cloudflare account ID | `string` | n/a | yes |
| buckets | List of R2 buckets to create | `list(object({   name     = string   location   = optional(string, "eeur")   jurisdiction = optional(string, "eu")   storage_class = optional(string, "Standard")   cors_rules = optional(list(object({    id       = optional(string)    allowed_methods = list(string)    allowed_origins = list(string)    allowed_headers = optional(list(string))    expose_headers = optional(list(string))    max_age_seconds = optional(number)   })), [])   custom_domains = optional(list(object({    domain = string    zone_id = string    enabled = optional(bool, true)    min_tls = optional(string)   })), [])  }))` | `[]` | no |
## Outputs

| Name | Description |
|------|-------------|
| bucket_cors | Map of R2 bucket CORS configurations |
| buckets | Map of R2 buckets created |
| custom_domains | Map of R2 custom domain bindings |
<!-- END_TF_DOCS -->
