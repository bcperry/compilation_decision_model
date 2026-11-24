using '../main.bicep'

param location = 'eastus2'
param resourceGroupName = 'rg-compilation-decision-dev-eus2'
param resourcePrefix = 'cdm-dev'
param tags = {
  project: 'compilation-decision-model'
  environment: 'dev'
}
param appServiceSku = 'F1'
param documentIntelligenceSku = 'F0'
param foundrySku = 'S0'
param modelName = 'Microsoft-Decision-1.1'
param modelVersion = '1'
param modelFormat = 'Microsoft'
param modelDeploymentName = 'decision'
param modelSku = 'DataZoneStandard'
param modelCapacity = 1
param storageSku = 'Standard_LRS'
param postgresSku = 'Standard_B2s'
param postgresVersion = '17'
param postgresStorageGB = 32
param postgresAdministratorObjectId = readEnvironmentVariable('AZURE_POSTGRES_ADMIN_OBJECT_ID')
param postgresAdministratorName = readEnvironmentVariable('AZURE_POSTGRES_ADMIN_NAME')
