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
  source = "git::git@github.com:AutomationDojo/tf-module-cloudflare.git//modules/r2?ref=v1.0.0"

  account_id = var.cloudflare_account_id

  buckets = [
    {
      name     = "my-storage-bucket"
      location = "auto"
    },
    {
      name     = "eu-data-bucket"
      location = "WEUR"
    }
  ]
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_cloudflare"></a> [cloudflare](#requirement\_cloudflare) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_cloudflare"></a> [cloudflare](#provider\_cloudflare) | ~> 4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [cloudflare_r2_bucket.buckets](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/r2_bucket) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | Cloudflare account ID | `string` | n/a | yes |
| <a name="input_buckets"></a> [buckets](#input\_buckets) | List of R2 buckets to create | <pre>list(object({<br/>    name     = string<br/>    location = optional(string, "EEUR")<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_buckets"></a> [buckets](#output\_buckets) | Map of R2 buckets created |
<!-- END_TF_DOCS -->
