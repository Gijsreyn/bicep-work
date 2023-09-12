@description('The storage account name')
param stgName string

@description('The resource group lication')
param location string = resourceGroup().location

param deployStorageAccount bool = false

module stg '../resources/resource-storageaccount.bicep' = if (deployStorageAccount) {
  name: stgName
  params: {
    // location: location
  }
}
