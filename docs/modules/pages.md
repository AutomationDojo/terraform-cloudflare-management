# Pages Module

The Pages module enables you to create and manage Cloudflare Pages projects with GitHub integration for automatic deployments.

## Features

- **GitHub Integration**: Automatic CI/CD from your GitHub repository
- **Custom Domains**: Configure custom domains with automatic SSL/TLS certificates
- **Deployment Configs**: Flexible per-environment configuration (production/preview)
- **Multiple Projects**: Manage multiple Pages projects from a single module
- **Monorepo Support**: Configure `root_dir` for projects in subdirectories

## Basic Usage

```hcl
module "pages" {
  source = "git::git@github.com:AutomationDojo/tf-module-cloudflare.git//modules/pages?ref=v2.0.1"

  account_id = var.cloudflare_account_id

  projects = {
    my-website = {
      name              = "my-website"
      production_branch = "main"
      github_owner      = "my-org"
      github_repo       = "my-website"
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
  source = "git::git@github.com:AutomationDojo/tf-module-cloudflare.git//modules/pages?ref=v2.0.1"

  account_id = var.cloudflare_account_id

  projects = {
    marketing-site = {
      name              = "marketing-site"
      production_branch = "main"
      github_owner      = "company"
      github_repo       = "marketing"
      build_command     = "npm run build"
      destination_dir   = "public"
      custom_domain     = "www.example.com"
    }
  }
}
```

### With Deployment Configs (Environment Variables per Environment)

You can use **`environment_variables`** (simple `map(string)`, all plain text) or **`env_vars`** (full control with `value` and `type` for secrets).

**Simple form (plain text only):**

```hcl
module "pages" {
  source = "git::git@github.com:AutomationDojo/tf-module-cloudflare.git//modules/pages?ref=v2.0.1"

  account_id = var.cloudflare_account_id

  projects = {
    api-docs = {
      name              = "api-docs"
      production_branch = "main"
      github_owner      = "company"
      github_repo       = "api-docs"
      build_command     = "npm run build"
      destination_dir   = "build"

      deployment_configs = {
        production = {
          environment_variables = {
            NODE_VERSION = "22"
            API_URL      = "https://api.example.com"
          }
          compatibility_date  = "2024-01-01"
          compatibility_flags = ["nodejs_compat"]
        }
        preview = {
          environment_variables = {
            NODE_VERSION = "22"
            API_URL      = "https://api.staging.example.com"
          }
        }
      }
    }
  }
}
```

**Full form with secrets (`env_vars`):**

Use `env_vars` when you need to mark a value as a secret (e.g. API keys). Types: `plain_text` (default) or `secret`.

```hcl
      deployment_configs = {
        production = {
          environment_variables = {
            NODE_VERSION = "22"
          }
          env_vars = {
            API_KEY = {
              value = var.api_key
              type  = "secret"
            }
            API_URL = {
              value = "https://api.example.com"
              type  = "plain_text"
            }
          }
          compatibility_date  = "2024-01-01"
          compatibility_flags = ["nodejs_compat"]
        }
      }
```

Both forms can be combined; `env_vars` takes precedence for the same key.

### Monorepo Setup (with root_dir)

```hcl
module "pages" {
  source = "git::git@github.com:AutomationDojo/tf-module-cloudflare.git//modules/pages?ref=v2.0.1"

  account_id = var.cloudflare_account_id

  projects = {
    frontend = {
      name              = "my-frontend"
      production_branch = "main"
      github_owner      = "company"
      github_repo       = "monorepo"
      build_command     = "npm run build"
      destination_dir   = "out"
      root_dir          = "apps/frontend"  # Code is in a subdirectory
    }
  }
}
```

### With Preview Deployment Settings

```hcl
module "pages" {
  source = "git::git@github.com:AutomationDojo/tf-module-cloudflare.git//modules/pages?ref=v2.0.1"

  account_id = var.cloudflare_account_id

  projects = {
    production-site = {
      name                       = "production-site"
      production_branch          = "main"
      github_owner               = "company"
      github_repo                = "website"
      build_command              = "npm run build"
      destination_dir            = "dist"
      preview_deployment_setting = "none"  # Disable preview deployments
    }

    staging-site = {
      name                       = "staging-site"
      production_branch          = "main"
      github_owner               = "company"
      github_repo                = "staging"
      build_command              = "npm run build"
      destination_dir            = "dist"
      preview_deployment_setting = "all"   # Enable preview deployments
      preview_branch_includes    = ["dev", "feature/*"]  # Only these branches
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
| `name` | Project name (lowercase, hyphens only, no dots) | `string` | Yes | - |
| `production_branch` | Git branch for production | `string` | Yes | - |
| `github_owner` | GitHub user or organization | `string` | Yes | - |
| `github_repo` | GitHub repository name | `string` | Yes | - |
| `build_command` | Build command to run | `string` | Yes | - |
| `destination_dir` | Output directory after build | `string` | Yes | - |
| `root_dir` | Root directory for monorepo setups | `string` | No | `""` |
| `custom_domain` | Custom domain for the project | `string` | No | `null` |
| `preview_deployment_setting` | Preview deployment setting (`"none"` or `"all"`) | `string` | No | `"none"` |
| `preview_branch_includes` | Branches to include for preview deployments | `list(string)` | No | `[]` |
| `deployment_configs` | Per-environment deployment configuration | `map(object)` | No | `{}` |

### Deployment Config Object

| Field | Description | Type | Default |
|-------|-------------|------|---------|
| `environment_variables` | Simple env vars (plain text). Key-value map. Merged with `env_vars`; `env_vars` wins on same key. | `map(string)` | `{}` |
| `env_vars` | Env vars with type (`plain_text` or `secret`). Use for secrets. Each entry: `{ value = string, type = optional(string, "plain_text") }`. | `map(object)` | `{}` |
| `compatibility_date` | Workers compatibility date | `string` | `"2024-01-01"` |
| `compatibility_flags` | Workers compatibility flags | `list(string)` | `[]` |

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
    Project names must be lowercase with hyphens only (no dots). For example, use `my-site` instead of `my.site`.

!!! tip "Environment Variables"
    Use `deployment_configs` to set different environment variables for production and preview. Use **`environment_variables`** (map of string) for plain text, or **`env_vars`** (map of `{ value, type }`) for secrets (`type = "secret"`). Both can be used together; `env_vars` overrides for the same key. For runtime variables in frameworks like Next.js, use the appropriate prefix (e.g., `NEXT_PUBLIC_`).

!!! info "Preview Deployments"
    The `preview_deployment_setting` controls automatic deployments for non-production branches:

    - `"none"`: Disables preview deployments (default)
    - `"all"`: Enables preview deployments for all branches

    Use `preview_branch_includes` to limit which branches trigger preview deployments.

## Related

- [Complete Setup Example](../examples/complete-setup.md)
- [DNS Module](dns.md) - Configure DNS records
- [Cloudflare Pages Documentation](https://developers.cloudflare.com/pages/)
