# Power-Pages-Project-Template

## Overview

This repository is used to manage and document Power Pages sites. It contains:

- **Site Documentation:**
  - Markdown documentation for each Power Pages site, including details on web roles, page permissions, table permissions, and site settings.
  - Security documentation for each site, generated in a consistent format.

- **Automation Scripts:**
  - PowerShell scripts for uploading and downloading site files using the Microsoft Power Platform CLI (PAC CLI).
  - Scripts to generate Markdown documentation from site YAML files, making it easy to review and share site configuration and security details.

## Key Folders

- `sites/` — Contains the YAML source files for each Power Pages site.
- `docs/` — Contains generated Markdown documentation for each site.
- `scripts/utilities/` — Contains core PowerShell scripts for upload, download, and documentation generation.
- `scripts/` — Contains environment-specific helper scripts for common operations.

## Getting Started

1. Use the download scripts to pull site files from your Power Platform environment.
2. Use the documentation generation scripts to create Markdown docs for each site.
3. Use the upload scripts to push changes back to your environment.

All scripts rely on the PAC CLI. Make sure it is installed and available in your PATH.