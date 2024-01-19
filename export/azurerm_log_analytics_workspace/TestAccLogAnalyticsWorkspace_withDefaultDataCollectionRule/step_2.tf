
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025258333673"
  location = "West Europe"
}

resource "azurerm_monitor_data_collection_rule" "test" {
  name                = "acctestmdcr-240119025258333673"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.test.id
      name                  = "test-destination"
    }
  }

  data_flow {
    streams      = ["Microsoft-InsightsMetrics"]
    destinations = ["test-destination"]
  }
}

resource "azurerm_log_analytics_workspace" "test" {
  name                    = "acctestLAW-240119025258333673"
  location                = azurerm_resource_group.test.location
  resource_group_name     = azurerm_resource_group.test.name
  sku                     = "PerGB2018"
  retention_in_days       = 30
  data_collection_rule_id = "/subscriptions/ARM_SUBSCRIPTION_ID/resourceGroups/acctestRG-240119025258333673/providers/Microsoft.Insights/dataCollectionRules/acctestmdcr-240119025258333673"
}
