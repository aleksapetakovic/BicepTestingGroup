//workspace name (automatically assigned during sentinel content deployment)
param workspace string

//watchlist properties (edit)
var displayName = 'Playground Watchlist Template'
var description = 'Watchlist queried by xxx'
var searchKey = 'CustomerWorkspaceId'
var csvFileName = '_playbookTemplate.csv'
var watchlistVersion = 1 //used to trigger deployments (/fail safe)

//preset properties (do not edit)
var watchlistProvider = 'baseVISION SOC'
var source = 'GitHub Repository'
var resourceGuid = guid(displayName,resourceGroup().id, subscription().subscriptionId)


resource symbolicname 'Microsoft.OperationalInsights/workspaces/providers/Watchlists@2021-03-01-preview' = {
  name: '${workspace}/Microsoft.SecurityInsights/${resourceGuid}'
  kind: ''
  properties: {
    displayName: displayName
    source: source
    description: description
    provider: watchlistProvider
    isDeleted: false
    labels: []
    defaultDuration: 'P1000Y'
    contentType: 'Text/Csv'
    numberOfLinesToSkip: 0
    itemsSearchKey: searchKey
    rawContent: format('''{0}''', loadTextContent(csvFileName)) //allow multi line strings from csv files
  }
}
     