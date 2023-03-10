// name of the logic app and the log analytics workspace (edit)
var logicAppName = 'la-mssentinel-playGround'

// api connection / uami definition (edit only if you changed the uami name)
var userAssignedIdentityName = 'mi-sentinel-playbooks'
var sentinelApiConnectionName = '${userAssignedIdentityName}-connection'

// reference the user-assigned managed identity
resource userAssignedManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  name: userAssignedIdentityName
}

// reference the sentinel api connection
resource sentinelApiConnection 'Microsoft.Web/connections@2016-06-01' existing = {
  name: sentinelApiConnectionName
}

// describe the playbook
resource playbook 'Microsoft.Logic/workflows@2017-07-01' = {
  name: logicAppName
  location: resourceGroup().location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedManagedIdentity.id}': {}
    }
  }
  properties: {
    state: 'Enabled'
    parameters:{
      '$connections': {
        value: {
          azuresentinel: {
            connectionId: sentinelApiConnection.id
            connectionName: sentinelApiConnection.name
            connectionProperties: {
              authentication: {
                identity: userAssignedManagedIdentity.id
                type: 'ManagedServiceIdentity'
              }
            }
            id: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Web/locations/${resourceGroup().location}/managedApis/azuresentinel'
          }
        }
      }
    }
    definition: {
      '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
      contentVersion: '1.0.0.0'
      parameters: {
        '$connections': {
          defaultValue: {}
          type: 'Object'
        }
      }
      triggers: {
        Microsoft_Sentinel_incident: {
          type: 'ApiConnectionWebhook'
          inputs: {
            body: {
              callback_url: '@{listCallbackUrl()}'
            }
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'azuresentinel\'][\'connectionId\']'
              }
            }
            path: '/subscribe'
          }
        }
      }
      actions: {
        'Add_comment_to_incident_(V3)': {
          inputs: {
            body: {
              incidentArmId: '@triggerBody()?[\'object\']?[\'id\']'
              message: 'bicep rocks!!!'
            }
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'azuresentinel\'][\'connectionId\']'
              }
            }
            method: 'post'
            path: '/Incidents/Comment'
          }
          runAfter: {}
          type: 'ApiConnection'
        }
      }
      outputs: {}
    }
  }
}
