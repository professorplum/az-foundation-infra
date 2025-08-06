# Foundation Infrastructure

## Overview

This directory contains generic, reusable Infrastructure as Code (IaC) components for Azure that can be used across any project. These modules and templates are designed to be app-agnostic and follow Azure best practices.

## Philosophy

- **Generic First**: All components are designed to be reusable across different applications
- **Parameterized**: Extensive use of parameters to customize behavior without code changes
- **Best Practices**: Follows Azure Well-Architected Framework principles
- **Modular**: Small, focused modules that can be composed into larger solutions
- **Testable**: All infrastructure includes validation and testing capabilities

## Directory Structure

```
foundation-infrastructure/
├── modules/                  # Individual Azure resource modules
│   ├── resource-group/       # Resource group with standard naming
│   ├── keyvault/            # Key Vault with security best practices
│   └── storage-account/     # Storage account with various configurations
├── templates/               # Composed infrastructure stacks
│   └── basic-web-app.bicep # Simple web app with database
├── scripts/                 # Deployment and management scripts
│   └── deploy.sh           # Main deployment script
└── parameters/              # Environment-specific parameters
    ├── dev.parameters.json
    ├── staging.parameters.json
    └── prod.parameters.json
```

## Quick Start

### Prerequisites

- Azure CLI installed and authenticated
- Bicep CLI installed
- Appropriate Azure permissions (Contributor or higher)

### Basic Usage

1. **Deploy a simple web app stack:**
```bash
az deployment sub create \
  --location "East US 2" \
  --template-file templates/basic-web-app.bicep \
  --parameters @parameters/dev.parameters.json
```

2. **Deploy individual modules:**
```bash
az deployment group create \
  --resource-group "rg-myapp-dev" \
  --template-file modules/keyvault/main.bicep \
  --parameters appName="myapp" environment="dev"
```

### Customization

All modules accept common parameters:
- `appName`: Your application name (used in resource naming)
- `environment`: Environment name (dev/staging/prod)
- `location`: Azure region
- `commonTags`: Tags applied to all resources

## Best Practices

- Use consistent naming conventions across environments
- Apply appropriate tags for cost management and organization
- Follow principle of least privilege for access controls
- Enable monitoring and diagnostics where applicable
- Use managed identities instead of service principals when possible