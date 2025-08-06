#!/bin/bash

# Foundation Infrastructure Deployment Script
# Usage: ./deploy.sh <template> <environment> <app-name> [resource-group]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if required parameters are provided
if [ $# -lt 3 ]; then
    print_error "Usage: $0 <template> <environment> <app-name> [resource-group]"
    print_error "Example: $0 basic-web-app dev myapp"
    exit 1
fi

TEMPLATE=$1
ENVIRONMENT=$2
APP_NAME=$3
RESOURCE_GROUP=${4:-"rg-${APP_NAME}-${ENVIRONMENT}"}

# Validate template exists
TEMPLATE_PATH="../templates/${TEMPLATE}.bicep"
if [ ! -f "$TEMPLATE_PATH" ]; then
    print_error "Template file not found: $TEMPLATE_PATH"
    exit 1
fi

# Validate parameters file exists
PARAMETERS_PATH="../parameters/${ENVIRONMENT}.parameters.json"
if [ ! -f "$PARAMETERS_PATH" ]; then
    print_error "Parameters file not found: $PARAMETERS_PATH"
    exit 1
fi

print_status "Starting deployment..."
print_status "Template: $TEMPLATE"
print_status "Environment: $ENVIRONMENT"
print_status "App Name: $APP_NAME"
print_status "Resource Group: $RESOURCE_GROUP"

# Check if Azure CLI is installed and user is logged in
if ! command -v az &> /dev/null; then
    print_error "Azure CLI is not installed or not in PATH"
    exit 1
fi

if ! az account show &> /dev/null; then
    print_error "Not logged in to Azure. Please run 'az login'"
    exit 1
fi

# Get current subscription info
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
SUBSCRIPTION_NAME=$(az account show --query name -o tsv)
print_status "Using subscription: $SUBSCRIPTION_NAME ($SUBSCRIPTION_ID)"

# Validate the template
print_status "Validating Bicep template..."
az bicep build --file "$TEMPLATE_PATH"

# Create resource group if it doesn't exist
if ! az group show --name "$RESOURCE_GROUP" &> /dev/null; then
    print_status "Creating resource group: $RESOURCE_GROUP"
    az group create --name "$RESOURCE_GROUP" --location "East US 2"
else
    print_status "Using existing resource group: $RESOURCE_GROUP"
fi

# Deploy the template
print_status "Deploying infrastructure..."
DEPLOYMENT_NAME="${TEMPLATE}-$(date +%Y%m%d-%H%M%S)"

az deployment group create \
    --resource-group "$RESOURCE_GROUP" \
    --template-file "$TEMPLATE_PATH" \
    --parameters "@${PARAMETERS_PATH}" \
    --parameters appName="$APP_NAME" environment="$ENVIRONMENT" \
    --name "$DEPLOYMENT_NAME" \
    --verbose

if [ $? -eq 0 ]; then
    print_status "Deployment completed successfully!"
    print_status "Deployment name: $DEPLOYMENT_NAME"
    
    # Show deployment outputs
    print_status "Deployment outputs:"
    az deployment group show \
        --resource-group "$RESOURCE_GROUP" \
        --name "$DEPLOYMENT_NAME" \
        --query properties.outputs
else
    print_error "Deployment failed!"
    exit 1
fi