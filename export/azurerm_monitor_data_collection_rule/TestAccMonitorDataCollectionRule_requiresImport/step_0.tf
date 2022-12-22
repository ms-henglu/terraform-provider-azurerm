

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-DataCollectionRule-221222035024328465"
  location = "West Europe"
}



resource "azurerm_monitor_data_collection_rule" "test" {
  name                = "acctestmdcr-221222035024328465"
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
