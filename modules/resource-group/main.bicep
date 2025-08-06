@description('Application name for resource naming')
param appName string

@description('Environment (dev, staging, prod)')
param environment string

@description('Azure region for resources')
param location string

@description('Common tags for all resources')
param commonTags object = {}

@description('Additional Resource Group specific tags')
param resourceGroupTags object = {}

// Variables
var resourceGroupName = 'rg-${appName}-${environment}'

// Merge tags
var allTags = union(commonTags, resourceGroupTags, {
  ResourceType: 'ResourceGroup'
  Purpose: 'ApplicationResources'
  Environment: environment
  Application: appName
})

// Resource Group
resource resourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: resourceGroupName
  location: location
  tags: allTags
}

// Outputs
output resourceGroupName string = resourceGroup.name
output resourceGroupId string = resourceGroup.id
output location string = resourceGroup.location