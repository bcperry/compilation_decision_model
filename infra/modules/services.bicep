param location string
param resourcePrefix string
param suffix string
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

resource hostingPlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: '${resourcePrefix}-plan'
  location: location
  kind: 'linux'
  tags: tags
  sku: {
    name: appServiceSku
  }
  properties: {
    reserved: true
  }
}

resource app 'Microsoft.Web/sites@2023-12-01' = {
  name: '${resourcePrefix}-app-${suffix}'
  location: location
  kind: 'app,linux'
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: hostingPlan.id
    httpsOnly: true
    publicNetworkAccess: 'Enabled'
    siteConfig: {
      linuxFxVersion: 'PYTHON|3.14'
      minTlsVersion: '1.2'
      ipSecurityRestrictionsDefaultAction: 'Deny'
      scmIpSecurityRestrictionsDefaultAction: 'Deny'
      scmIpSecurityRestrictionsUseMain: false
    }
  }
}

resource documentIntelligence 'Microsoft.CognitiveServices/accounts@2025-06-01' = {
  name: '${resourcePrefix}-doc-${suffix}'
  location: location
  kind: 'FormRecognizer'
  tags: tags
  sku: {
    name: documentIntelligenceSku
  }
  properties: {
    customSubDomainName: '${resourcePrefix}-doc-${suffix}'
    disableLocalAuth: true
    publicNetworkAccess: 'Enabled'
  }
}

resource foundry 'Microsoft.CognitiveServices/accounts@2025-06-01' = {
  name: '${resourcePrefix}-ai-${suffix}'
  location: location
  kind: 'AIServices'
  tags: tags
  sku: {
    name: foundrySku
  }
  properties: {
    customSubDomainName: '${resourcePrefix}-ai-${suffix}'
    disableLocalAuth: true
    publicNetworkAccess: 'Enabled'
  }
}

resource decisionModel 'Microsoft.CognitiveServices/accounts/deployments@2025-06-01' = {
  parent: foundry
  name: modelDeploymentName
  sku: {
    name: modelSku
    capacity: modelCapacity
  }
  properties: {
    model: {
      name: modelName
      format: modelFormat
      version: modelVersion
    }
    versionUpgradeOption: 'NoAutoUpgrade'
  }
}

output resources object = {
  hostingPlan: hostingPlan.name
  app: app.name
  documentIntelligence: documentIntelligence.name
  foundry: foundry.name
  decisionModel: decisionModel.name
}
