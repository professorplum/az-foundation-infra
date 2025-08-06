@description('Application name for resource naming')
param appName string

@description('Environment (dev, staging, prod)')
param environment string

@description('Azure region for resources')
param location string = 'East US 2'

@description('Common tags for all resources')
param commonTags object = {}

@description('Enable purge protection for Key Vault')
param enablePurgeProtection bool = false

@description('Storage account SKU')
param storageAccountSku string = 'Standard_LRS'

@description('API Management SKU')
param apimSku string = 'Developer'

@description('Publisher email for API Management')
param publisherEmail string

@description('Publisher name for API Management')
param publisherName string

// Resource Group
module resourceGroup '../modules/resource-group/main.bicep' = {
  name: 'resourceGroup'
  params: {
    appName: appName
    environment: environment
    location: location
    commonTags: commonTags
  }
}

// Key Vault
module keyVault '../modules/keyvault/main.bicep' = {
  name: 'keyVault'
  scope: resourceGroup(resourceGroup.outputs.resourceGroupName)
  params: {
    appName: appName
    environment: environment
    location: location
    commonTags: commonTags
    enablePurgeProtection: enablePurgeProtection
  }
}

// Storage Account
module storageAccount '../modules/storage-account/main.bicep' = {
  name: 'storageAccount'
  scope: resourceGroup(resourceGroup.outputs.resourceGroupName)
  params: {
    appName: appName
    environment: environment
    location: location
    commonTags: commonTags
    skuName: storageAccountSku
  }
}

// API Management
module apiManagement '../modules/api-management/main.bicep' = {
  name: 'apiManagement'
  scope: resourceGroup(resourceGroup.outputs.resourceGroupName)
  params: {
    appName: appName
    environment: environment
    location: location
    commonTags: commonTags
    skuName: apimSku
    publisherEmail: publisherEmail
    publisherName: publisherName
  }
}

// Outputs
output resourceGroupName string = resourceGroup.outputs.resourceGroupName
output keyVaultName string = keyVault.outputs.keyVaultName
output keyVaultUri string = keyVault.outputs.keyVaultUri
output storageAccountName string = storageAccount.outputs.storageAccountName
output apimName string = apiManagement.outputs.apimName
output apimGatewayUrl string = apiManagement.outputs.gatewayUrl
output apimPortalUrl string = apiManagement.outputs.portalUrl