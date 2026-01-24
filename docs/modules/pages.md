# Pages Module

The Pages module enables you to create and manage Cloudflare Pages projects with GitHub integration for automatic deployments.

## Features

- **GitHub Integration**: Automatic CI/CD from your GitHub repository
- **Custom Domains**: Configure custom domains with automatic SSL/TLS certificates
- **Environment Variables**: Set build-time and runtime environment variables
- **Multiple Projects**: Manage multiple Pages projects from a single module
- **Production & Preview**: Automatic deployments for production and preview branches

## Basic Usage

```hcl
module "pages" {
  source = "git::git@github.com:AutomationDojo/tf-module-cloudflare.git//modules/pages?ref=v2.0.0"

  account_id = var.cloudflare_account_id

  projects = {
    my-website = {
      name              = "my-website"
      production_branch = "main"
      github_repo       = "my-org/my-website"
      build_command     = "npm run build"
      destination_dir   = "dist"
    }
  }
}
```

## Advanced Usage

### With Custom Domain

```hcl
module "pages" {
  source = "git::git@github.com:AutomationDojo/tf-module-cloudflare.git//modules/pages?ref=v2.0.0"

  account_id = var.cloudflare_account_id

  projects = {
    marketing-site = {
      name              = "marketing-site"
      production_branch = "main"
      github_repo       = "company/marketing"
      build_command     = "npm run build"
      destination_dir   = "public"
      custom_domain     = "www.example.com"
    }
  }
}
```

### With Environment Variables

```hcl
module "pages" {
  source = "git::git@github.com:AutomationDojo/tf-module-cloudflare.git//modules/pages?ref=v2.0.0"

  account_id = var.cloudflare_account_id

  projects = {
    api-docs = {
      name              = "api-docs"
      production_branch = "main"
      github_repo       = "company/api-docs"
      build_command     = "npm run build"
      destination_dir   = "build"
      environment_variables = {
        NODE_VERSION = "20"
        NPM_VERSION  = "10"
        API_URL      = "https://api.example.com"
      }
    }
  }
}
```

### With Preview Deployment Settings

```hcl
module "pages" {
  source = "git::git@github.com:AutomationDojo/tf-module-cloudflare.git//modules/pages?ref=v2.0.0"

  account_id = var.cloudflare_account_id

  projects = {
    production-site = {
      name                       = "production-site"
      production_branch          = "main"
      github_repo                = "company/website"
      build_command              = "npm run build"
      destination_dir            = "dist"
      preview_deployment_setting = "none"  # Disable preview deployments
    }

    staging-site = {
      name                       = "staging-site"
      production_branch          = "main"
      github_repo                = "company/staging"
      build_command              = "npm run build"
      destination_dir            = "dist"
      preview_deployment_setting = "all"  # Enable preview deployments for all branches
    }
  }
}
```

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| `account_id` | Cloudflare account ID | `string` | Yes |
| `projects` | Map of Cloudflare Pages projects | `map(object)` | Yes |

### Project Object

| Field | Description | Type | Required | Default |
|-------|-------------|------|----------|---------|
| `name` | Project name (must be unique) | `string` | Yes | - |
| `production_branch` | Git branch for production | `string` | Yes | - |
| `github_repo` | GitHub repository (format: `owner/repo`) | `string` | Yes | - |
| `build_command` | Build command to run | `string` | Yes | - |
| `destination_dir` | Output directory after build | `string` | Yes | - |
| `custom_domain` | Custom domain for the project | `string` | No | `null` |
| `preview_deployment_setting` | Preview deployment setting (`"none"` or `"all"`) | `string` | No | `"none"` |
| `environment_variables` | Build environment variables | `map(string)` | No | `{}` |

## Outputs

| Name | Description |
|------|-------------|
| `projects` | Map of all Cloudflare Pages projects |
| `default_urls` | Map of default `pages.dev` URLs |
| `custom_domains` | Map of configured custom domains |

### Example Output Usage

```hcl
output "website_url" {
  description = "Production URL for the marketing site"
  value       = module.pages.custom_domains["marketing-site"]
}

output "preview_url" {
  description = "Default pages.dev URL"
  value       = module.pages.default_urls["marketing-site"]
}
```

## Framework Support

Cloudflare Pages supports many popular frameworks out of the box:

- **Static Site Generators**: Hugo, Jekyll, Eleventy, MkDocs
- **React Frameworks**: Next.js, Gatsby, Create React App
- **Vue Frameworks**: Nuxt, VuePress, Gridsome
- **Other**: Svelte, SvelteKit, Astro, Remix

## Prerequisites

1. **GitHub Repository**: Your code must be in a GitHub repository
2. **Cloudflare Account**: You need a Cloudflare account
3. **GitHub OAuth**: Cloudflare needs to be connected to your GitHub account (done via Cloudflare dashboard)

## DNS Configuration

When using custom domains, ensure:

1. Your domain is added to Cloudflare
2. DNS records point to Cloudflare's nameservers
3. The custom domain DNS record will be automatically managed by Cloudflare Pages

## Important Notes

!!! info "Build Configuration"
    The build configuration (build command, destination directory) must match your framework's requirements.

!!! warning "Project Names"
    Project names must be globally unique across all Cloudflare Pages projects.

!!! tip "Environment Variables"
    Environment variables are available during build time. For runtime variables in frameworks like Next.js, use the appropriate prefix (e.g., `NEXT_PUBLIC_`).

!!! info "Preview Deployments"
    The `preview_deployment_setting` controls automatic deployments for non-production branches:

    - `"none"`: Disables preview deployments (default)
    - `"all"`: Enables preview deployments for all branches

    Use `"none"` for production sites to avoid unnecessary builds, or `"all"` for development/staging environments where you want to preview changes from all branches.

## Related

- [Complete Setup Example](../examples/complete-setup.md)
- [DNS Module](dns.md) - Configure DNS records
- [Cloudflare Pages Documentation](https://developers.cloudflare.com/pages/)
