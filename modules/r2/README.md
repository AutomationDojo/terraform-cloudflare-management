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
  source = "git::git@github.com:AutomationDojo/tf-module-cloudflare.git//modules/r2?ref=v2.0.1"

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
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_cloudflare"></a> [cloudflare](#requirement\_cloudflare) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_cloudflare"></a> [cloudflare](#provider\_cloudflare) | 5.17.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [cloudflare_r2_bucket.buckets](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/r2_bucket) | resource |
| [cloudflare_r2_bucket_cors.cors](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/r2_bucket_cors) | resource |
| [cloudflare_r2_custom_domain.domains](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/r2_custom_domain) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | Cloudflare account ID | `string` | n/a | yes |
| <a name="input_buckets"></a> [buckets](#input\_buckets) | List of R2 buckets to create | <pre>list(object({<br/>    name          = string<br/>    location      = optional(string, "eeur")<br/>    jurisdiction  = optional(string, "eu")<br/>    storage_class = optional(string, "Standard")<br/>    cors_rules = optional(list(object({<br/>      id              = optional(string)<br/>      allowed_methods = list(string)<br/>      allowed_origins = list(string)<br/>      allowed_headers = optional(list(string))<br/>      expose_headers  = optional(list(string))<br/>      max_age_seconds = optional(number)<br/>    })), [])<br/>    custom_domains = optional(list(object({<br/>      domain  = string<br/>      zone_id = string<br/>      enabled = optional(bool, true)<br/>      min_tls = optional(string)<br/>    })), [])<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_cors"></a> [bucket\_cors](#output\_bucket\_cors) | Map of R2 bucket CORS configurations |
| <a name="output_buckets"></a> [buckets](#output\_buckets) | Map of R2 buckets created |
| <a name="output_custom_domains"></a> [custom\_domains](#output\_custom\_domains) | Map of R2 custom domain bindings |
<!-- END_TF_DOCS -->
