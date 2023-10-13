


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-DataCollectionRule-231013043849459818"
  location = "West Europe"
}



resource "azurerm_monitor_data_collection_rule" "test" {
  name                = "acctestmdcr-231013043849459818"
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


resource "azurerm_monitor_data_collection_rule" "import" {
  name                = azurerm_monitor_data_collection_rule.test.name
  resource_group_name = azurerm_monitor_data_collection_rule.test.resource_group_name
  location            = azurerm_monitor_data_collection_rule.test.location
  destinations {
    azure_monitor_metrics {
      name = azurerm_monitor_data_collection_rule.test.destinations.0.azure_monitor_metrics.0.name
    }
  }
  data_flow {
    streams      = azurerm_monitor_data_collection_rule.test.data_flow.0.streams
    destinations = azurerm_monitor_data_collection_rule.test.data_flow.0.destinations
  }
}
