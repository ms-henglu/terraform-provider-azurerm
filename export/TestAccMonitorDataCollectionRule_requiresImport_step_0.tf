

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-DataCollectionRule-220916011748393680"
  location = "West Europe"
}



resource "azurerm_monitor_data_collection_rule" "test" {
  name                = "acctestmdcr-220916011748393680"
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
