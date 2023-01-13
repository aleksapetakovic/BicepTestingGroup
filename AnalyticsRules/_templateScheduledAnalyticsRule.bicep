// workspace name (automatically assigned during sentinel content deployment)
param workspace string

// reference the workspace
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  name: workspace
}

// analytics rules properties (edit)
var ruleName = 'Playground Analytics Rules Template'
var description = 'Description'
var severity = 'Informational'

var query = '''SigninLogs
| take 1
'''

resource symbolicname 'Microsoft.SecurityInsights/alertRules@2022-10-01-preview' = {
    name: guid(ruleName, resourceGroup().id, subscription().subscriptionId)
    kind: 'Scheduled'
    scope: logAnalyticsWorkspace
    properties: {
      customDetails: {}
      description: description
      displayName: ruleName
      enabled: true
      eventGroupingSettings: {
        aggregationKind: 'SingleAlert'
      }
      incidentConfiguration: {
        createIncident: true
      }
      query: query
      queryFrequency: 'PT5H'
      queryPeriod: 'PT5H'
      severity: severity
      suppressionDuration: 'PT5H'
      suppressionEnabled: false
      tactics: [
      ]
      techniques: [
      ]
      triggerOperator: 'GreaterThan'
      triggerThreshold: 0
    }    
  }

