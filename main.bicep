targetScope = 'tenant'

param toplevelPrefix string = 'sbx'

@description('Specifies the billing scope under which all the subscriptions will be created')
param billingScope string

@description('Specifies all the management groups infos')
param managementGroups array

@description('Specifies the subscriptions infos')
param subscriptions array

@allowed([
  'canadacentral'
])
param location string = 'canadacentral'


resource mg 'Microsoft.Management/managementGroups@2021-04-01' = [for managementGroup in managementGroups: {
  name: managementGroup.name
  properties:{
    displayName: managementGroup.displayName
    details:{
      parent:{
        id: '/providers/Microsoft.Management/managementGroups/${managementGroup.parentMgmtGroupName}'
      }
    }
  }
}]


resource sub 'Microsoft.Subscription/aliases@2021-10-01' = [for subscription in subscriptions: {
  name: '${toplevelPrefix}-${subscription.name}'
  properties:{
    billingScope: billingScope
    workload: subscription.workloadType
    displayName: subscription.name
    additionalProperties:{
      managementGroupId: '/providers/Microsoft.Management/managementGroups/${subscription.parentMgmtGroupName}'
    }
  }
  dependsOn:[
    mg
  ]
}]

module rg 'modules/resourcegroup.bicep' = [for (subscription, i) in subscriptions: {
  scope: subscription(sub[i].id)
  name: 'deploy-rg-shared-${subscription.name}'
  params:{
    name: '${subscription.sharedResGroupName}'
    location: location
  }
  dependsOn:[
    sub
  ]
}]
