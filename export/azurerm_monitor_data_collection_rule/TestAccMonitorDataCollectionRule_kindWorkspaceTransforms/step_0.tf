

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-DataCollectionRule-240119022447679639"
  location = "West Europe"
}



resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctest-law-240119022447679639"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_monitor_data_collection_rule" "test" {
  name                = "acctestmdcr-240119022447679639"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  kind                = "WorkspaceTransforms"
  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.test.id
      name                  = "test-destination-log"
    }
  }

  data_flow {
    streams       = ["Microsoft-Table-LAQueryLogs"]
    destinations  = ["test-destination-log"]
    transform_kql = "source | where QueryText !contains 'LAQueryLogs' | extend Context = parse_json(RequestContext) | extend Resources_CF = tostring(Context['workspaces'])"
  }
}
