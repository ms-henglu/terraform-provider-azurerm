

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-DataCollectionRule-240119025423984492"
  location = "West Europe"
}



resource "azurerm_monitor_data_collection_rule" "test" {
  name                = "acctestmdcr-240119025423984492"
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
}
