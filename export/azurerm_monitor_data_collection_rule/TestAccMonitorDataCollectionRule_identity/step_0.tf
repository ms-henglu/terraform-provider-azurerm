

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-DataCollectionRule-240119025423988137"
  location = "West Europe"
}



resource "azurerm_user_assigned_identity" "test" {
  name                = "acctest240119025423988137"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_monitor_data_collection_rule" "test" {
  name                = "acctestmdcr-240119025423988137"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  destinations {
    azure_monitor_metrics {
      name = "test-destination-metrics"
    }
  }
  data_flow {
    streams      = ["Microsoft-InsightsMetrics"]
    destinations = ["test-destination-metrics"]
  }
  identity {
    type = "SystemAssigned"
  }
}
