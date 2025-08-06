@description('Application name for resource naming')
param appName string

@description('Environment (dev, staging, prod)')
param environment string

@description('Azure region for resources')
param location string = resourceGroup().location

@description('Common tags for all resources')
param commonTags object = {}

@description('API Management SKU')
@allowed(['Developer', 'Basic', 'Standard', 'Premium'])
param skuName string = 'Developer'

@description('Publisher email required for API Management')
param publisherEmail string

@description('Publisher name required for API Management')
param publisherName string

@description('Additional API Management specific tags')
param apimTags object = {}

// Variables
var apimServiceName = 'apim-${appName}-${environment}'

// Merge tags
var allTags = union(commonTags, apimTags, {
  ResourceType: 'ApiManagement'
  Purpose: 'ApiGateway'
  Environment: environment
  Application: appName
})

// API Management Service
resource apimService 'Microsoft.ApiManagement/service@2023-03-01-preview' = {
  name: apimServiceName
  location: location
  tags: allTags
  sku: {
    name: skuName
    capacity: 1
  }
  properties: {
    publisherEmail: publisherEmail
    publisherName: publisherName
    publicNetworkAccess: 'Enabled'
    virtualNetworkType: 'None'
  }
}

// Outputs
output apimName string = apimService.name
output apimId string = apimService.id
output gatewayUrl string = apimService.properties.gatewayUrl
output portalUrl string = apimService.properties.portalUrl
output managementApiUrl string = apimService.properties.managementApiUrl