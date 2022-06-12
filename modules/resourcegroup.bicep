targetScope = 'subscription'

@allowed([
  'canadacentral'
])
@description('Specifies the location for resource group.')
param location string = 'canadacentral'

@description('Specifies the name for resource group.')
param name string

resource resourcegroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: name
  location: location
  tags:{
    Owner:'mickael.lavroff'
  }
}
