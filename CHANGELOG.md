## [2.1.0](https://github.com/AutomationDojo/tf-module-cloudflare/compare/v2.0.1...v2.1.0) (2026-01-25)

### Features

* add tunnel module and docs ([#9](https://github.com/AutomationDojo/tf-module-cloudflare/issues/9)) ([12d364a](https://github.com/AutomationDojo/tf-module-cloudflare/commit/12d364a1b3885b47ef169e022fe761b898dcdffe))

## [2.0.1](https://github.com/AutomationDojo/tf-module-cloudflare/compare/v2.0.0...v2.0.1) (2026-01-24)

### Bug Fixes

* Update resource names ([#8](https://github.com/AutomationDojo/tf-module-cloudflare/issues/8)) ([604338f](https://github.com/AutomationDojo/tf-module-cloudflare/commit/604338f465e519388c20fad755922a8c8b1cc5dd))

## [2.0.0](https://github.com/AutomationDojo/tf-module-cloudflare/compare/v1.3.1...v2.0.0) (2026-01-24)

### ⚠ BREAKING CHANGES

* All modules now require Cloudflare provider v5.0 or higher.

- Updated provider version constraint from ~> 4.0 to ~> 5.0 across all modules
- DNS, Email, Pages, and R2 modules now require provider v5.0+
- R2 module: Added jurisdiction parameter for data residency compliance (eu, us, apac)
- R2 module: Added storage_class parameter for cost optimization (Standard, InfrequentAccess)
- Updated all module documentation and examples to reference v2.0.0
- Added R2 module to main documentation indices and feature lists
- Consolidated changelog to single source of truth in CHANGELOG.md

Migration: Users must upgrade to Cloudflare provider v5.0+ to use this version.

### Features

* upgrade all modules to Cloudflare provider v5.0 ([362e635](https://github.com/AutomationDojo/tf-module-cloudflare/commit/362e635a7cf9d09b5652e82ca998bcc83f49b47b))

## [1.3.1](https://github.com/AutomationDojo/tf-module-cloudflare/compare/v1.3.0...v1.3.1) (2026-01-24)

### Bug Fixes

* r2 module - missing options ([#6](https://github.com/AutomationDojo/tf-module-cloudflare/issues/6)) ([2b13496](https://github.com/AutomationDojo/tf-module-cloudflare/commit/2b134967fedf83a58f0e8938a9ce1dd65319914e))

## [1.3.0](https://github.com/AutomationDojo/tf-module-cloudflare/compare/v1.2.0...v1.3.0) (2026-01-24)

### Features

* R2 module ([#5](https://github.com/AutomationDojo/tf-module-cloudflare/issues/5)) ([02a57dc](https://github.com/AutomationDojo/tf-module-cloudflare/commit/02a57dca35807401256db2f0bf267cf9b20743dc))

## [1.2.0](https://github.com/AutomationDojo/tf-module-cloudflare/compare/v1.1.0...v1.2.0) (2025-12-26)

### Features

* add optional parameters ([#4](https://github.com/AutomationDojo/tf-module-cloudflare/issues/4)) ([440fcef](https://github.com/AutomationDojo/tf-module-cloudflare/commit/440fceff5ea11482bc46e31521b8cd0409eb6c88))

## [1.1.0](https://github.com/AutomationDojo/tf-module-cloudflare/compare/v1.0.0...v1.1.0) (2025-12-26)

### Features

* add email module ([e55d3dd](https://github.com/AutomationDojo/tf-module-cloudflare/commit/e55d3dd73aaf1f5c9fb15a4cb3095a5921af7228))

## 1.0.0 (2025-12-26)

### Features

* avoid concurrent commits ([53a3bcb](https://github.com/AutomationDojo/tf-module-cloudflare/commit/53a3bcb5bc5f6340823e3a9c41b2340d8f948285))
* setup module ([1a5df74](https://github.com/AutomationDojo/tf-module-cloudflare/commit/1a5df74b70b3acbec1c6cb4bb4e9ec6922be07a5))
* update depcrecated content ([626383e](https://github.com/AutomationDojo/tf-module-cloudflare/commit/626383e843befdc30f69b26047896fa3fe791915))
* update docs generation ([0b50566](https://github.com/AutomationDojo/tf-module-cloudflare/commit/0b505668d6a1e2b4125c116212644e5da7437634))

# Changelog

All notable changes to this project will be documented in this file.
