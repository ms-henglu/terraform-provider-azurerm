

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-DataCollectionRule-220819165500818221"
  location = "West Europe"
}



resource "azurerm_log_analytics_workspace" "test1" {
  name                = "acctest-law-220819165500818221"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_log_analytics_solution" "test1" {
  solution_name         = "WindowsEventForwarding"
  location              = azurerm_resource_group.test.location
  resource_group_name   = azurerm_resource_group.test.name
  workspace_resource_id = azurerm_log_analytics_workspace.test1.id
  workspace_name        = azurerm_log_analytics_workspace.test1.name
  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/WindowsEventForwarding"
  }
}

resource "azurerm_log_analytics_workspace" "test2" {
  name                = "acctest-law2-220819165500818221"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_log_analytics_solution" "test2" {
  solution_name         = "WindowsEventForwarding"
  location              = azurerm_resource_group.test.location
  resource_group_name   = azurerm_resource_group.test.name
  workspace_resource_id = azurerm_log_analytics_workspace.test1.id
  workspace_name        = azurerm_log_analytics_workspace.test1.name
  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/WindowsEventForwarding"
  }
}

resource "azurerm_monitor_data_collection_rule" "test" {
  name                = "acctestmdcr-220819165500818221"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.test1.id
      name                  = "test-destination-log1"
    }

    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.test2.id
      name                  = "test-destination-log2"
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
    destinations = ["test-destination-log1"]
  }

  data_flow {
    streams      = ["Microsoft-Event", "Microsoft-WindowsEvent"]
    destinations = ["test-destination-log1", "test-destination-log2"]
  }

  data_sources {
    syslog {
      facility_names = [
        "auth",
        "authpriv",
        "cron",
        "daemon",
        "kern",
      ]
      log_levels = [
        "Debug",
        "Info",
        "Notice",
      ]
      name = "test-datasource-syslog"
    }

    performance_counter {
      streams                       = ["Microsoft-Perf", "Microsoft-InsightsMetrics"]
      sampling_frequency_in_seconds = 10
      counter_specifiers = [
        "Processor(*)\\% Processor Time",
        "Processor(*)\\% Idle Time",
        "Processor(*)\\% User Time",
        "Processor(*)\\% Nice Time",
        "Processor(*)\\% Privileged Time",
        "Processor(*)\\% IO Wait Time",
        "Processor(*)\\% Interrupt Time",
        "Processor(*)\\% DPC Time",
      ]
      name = "test-datasource-perfcounter"
    }

    performance_counter {
      streams                       = ["Microsoft-Perf"]
      sampling_frequency_in_seconds = 20
      counter_specifiers = [
        "Network(*)\\Total Bytes Transmitted",
        "Network(*)\\Total Bytes Received",
        "Network(*)\\Total Bytes",
        "Network(*)\\Total Packets Transmitted",
        "Network(*)\\Total Packets Received",
        "Network(*)\\Total Rx Errors",
        "Network(*)\\Total Tx Errors",
        "Network(*)\\Total Collisions"
      ]
      name = "test-datasource-perfcounter2"
    }

    windows_event_log {
      streams        = ["Microsoft-WindowsEvent"]
      x_path_queries = ["*[System/Level=1]"]
      name           = "test-datasource-wineventlog"
    }

    extension {
      streams            = ["Microsoft-WindowsEvent"]
      input_data_sources = ["test-datasource-wineventlog"]
      extension_name     = "test-extension-name"
      extension_json = jsonencode({
        a = 1
        b = "hello"
      })
      name = "test-datasource-extension"
    }
  }

  description = "acc test monitor_data_collection_rule complete"
  tags = {
    ENV  = "test"
    ENV2 = "test2"
  }

  depends_on = [
    azurerm_log_analytics_solution.test1,
    azurerm_log_analytics_solution.test2,
  ]
}


