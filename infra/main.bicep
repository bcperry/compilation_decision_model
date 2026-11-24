targetScope = 'subscription'

param location string
param resourceGroupName string
param resourcePrefix string
param tags object
param appServiceSku string
param documentIntelligenceSku string
param foundrySku string
param modelName string
param modelVersion string
param modelFormat string
param modelDeploymentName string
param modelSku string
param modelCapacity int
param storageSku string
param postgresSku string
param postgresVersion string
param postgresStorageGB int
param postgresAdministratorObjectId string
param postgresAdministratorName string

var suffix = uniqueString(subscription().id, resourceGroupName)

resource resourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

module services 'modules/services.bicep' = {
  name: 'services'
  scope: resourceGroup
  params: {
    location: location
    resourcePrefix: resourcePrefix
    suffix: suffix
    tags: tags
    appServiceSku: appServiceSku
    documentIntelligenceSku: documentIntelligenceSku
    foundrySku: foundrySku
    modelName: modelName
    modelVersion: modelVersion
    modelFormat: modelFormat
    modelDeploymentName: modelDeploymentName
    modelSku: modelSku
    modelCapacity: modelCapacity
  }
}

module pdfStorage 'modules/pdf-storage.bicep' = {
  name: 'pdf-storage'
  scope: resourceGroup
  params: {
    location: location
    storageAccountName: '${replace(resourcePrefix, '-', '')}${suffix}'
    storageSku: storageSku
    tags: tags
  }
}

module postgresql 'modules/postgresql.bicep' = {
  name: 'postgresql'
  scope: resourceGroup
  params: {
    location: location
    serverName: '${resourcePrefix}-pg-${suffix}'
    skuName: postgresSku
    version: postgresVersion
    storageGB: postgresStorageGB
    administratorObjectId: postgresAdministratorObjectId
    administratorName: postgresAdministratorName
    tags: tags
  }
}

output resourceGroupName string = resourceGroup.name
output services object = services.outputs.resources
output pdfStorage object = pdfStorage.outputs.resources
output postgresql object = postgresql.outputs.resources
