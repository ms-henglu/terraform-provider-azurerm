

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-DataCollectionRule-240119025423989048"
  location = "westeurope"
}



resource "azurerm_log_analytics_workspace" "test" {
  name                               = "acctest-law-240119025423989048"
  location                           = azurerm_resource_group.test.location
  resource_group_name                = azurerm_resource_group.test.name
  sku                                = "CapacityReservation"
  reservation_capacity_in_gb_per_day = 100
}

resource "azurerm_log_analytics_solution" "test" {
  solution_name         = "WindowsEventForwarding"
  location              = azurerm_resource_group.test.location
  resource_group_name   = azurerm_resource_group.test.name
  workspace_resource_id = azurerm_log_analytics_workspace.test.id
  workspace_name        = azurerm_log_analytics_workspace.test.name
  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/WindowsEventForwarding"
  }
}

resource "azurerm_monitor_data_collection_rule" "test" {
  name                = "acctestmdcr-240119025423989048"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.test.id
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
      streams        = ["Microsoft-CiscoAsa"]
    }
    performance_counter {
      streams                       = ["Microsoft-Perf", "Microsoft-InsightsMetrics"]
      sampling_frequency_in_seconds = 60
      counter_specifiers            = ["Processor(*)\\% Processor Time"]
      name                          = "test-datasource-perfcounter"
    }
  }

  stream_declaration {
    stream_name = "Custom-MyTableRawData"
    column {
      name = "Time"
      type = "datetime"
    }
    column {
      name = "Computer"
      type = "string"
    }
    column {
      name = "AdditionalContext"
      type = "string"
    }
  }

  description = "acc test monitor_data_collection_rule"
  tags = {
    ENV = "test"
  }
}
