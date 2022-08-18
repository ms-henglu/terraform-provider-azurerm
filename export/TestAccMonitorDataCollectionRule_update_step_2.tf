

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-DataCollectionRule-220818235421991612"
  location = "West Europe"
}



resource "azurerm_log_analytics_workspace" "test1" {
  name                = "acctest-law-220818235421991612"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_monitor_data_collection_rule" "test" {
  name                = "acctestmdcr-220818235421991612"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.test1.id
      name                  = "test-destination-log"
    }
    azure_monitor_metrics {
      name = "test-destination-metrics"
    }
  }

  data_flow {
    streams      = ["Microsoft-InsightsMetrics"]
    destinations = ["test-destination-metrics"]
  }

  data_flow {
    streams      = ["Microsoft-InsightsMetrics", "Microsoft-Syslog", "Microsoft-Perf"]
    destinations = ["test-destination-log"]
  }

  data_sources {
    syslog {
      facility_names = ["*"]
      log_levels     = ["*"]
      name           = "test-datasource-syslog"
    }
    performance_counter {
      streams                       = ["Microsoft-Perf", "Microsoft-InsightsMetrics"]
      sampling_frequency_in_seconds = 10
      counter_specifiers            = ["Processor(*)\\% Processor Time"]
      name                          = "test-datasource-perfcounter"
    }
  }

  kind        = "Linux"
  description = "acc test monitor_data_collection_rule"
  tags = {
    ENV = "test"
  }
}
