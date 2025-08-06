@description('Application name for resource naming')
param appName string

@description('Environment (dev, staging, prod)')
param environment string

@description('Azure region for resources')
param location string = resourceGroup().location

@description('Common tags for all resources')
param commonTags object = {}

@description('Enable soft delete (recommended: true)')
param enableSoftDelete bool = true

@description('Enable purge protection (recommended: true for prod)')
param enablePurgeProtection bool = false

@description('Key Vault SKU')
@allowed(['standard', 'premium'])
param skuName string = 'standard'

@description('Additional Key Vault specific tags')
param keyVaultTags object = {}

@description('Network access rules')
@allowed(['Allow', 'Deny'])
param defaultAction string = 'Allow'

@description('Enable RBAC authorization (recommended: true)')
param enableRbacAuthorization bool = true

// Variables
var keyVaultName = 'kv-${appName}-${environment}-${uniqueString(resourceGroup().id)}'

// Merge tags
var allTags = union(commonTags, keyVaultTags, {
  ResourceType: 'KeyVault'
  Purpose: 'SecretStorage'
  Environment: environment
  Application: appName
})

// Key Vault
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  tags: allTags
  properties: {
    sku: {
      family: 'A'
      name: skuName
    }
    tenantId: subscription().tenantId
    enableSoftDelete: enableSoftDelete
    enablePurgeProtection: enablePurgeProtection
    enableRbacAuthorization: enableRbacAuthorization
    accessPolicies: []
    networkAcls: {
      defaultAction: defaultAction
      bypass: 'AzureServices'
    }
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: true
  }
}

// Outputs
output keyVaultName string = keyVault.name
output keyVaultId string = keyVault.id
output keyVaultUri string = keyVault.properties.vaultUri
output resourceId string = keyVault.id