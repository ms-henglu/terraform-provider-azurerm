

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-DataCollectionRule-240119025423982977"
  location = "westeurope"
}



resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestuai-240119025423982977"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_log_analytics_workspace" "test" {
  name                               = "acctest-law-240119025423982977"
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

resource "azurerm_eventhub_namespace" "test" {
  name                = "acceventn240119025423982977"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
  capacity            = 1
}

resource "azurerm_eventhub" "test" {
  name                = "accevent240119025423982977"
  namespace_name      = azurerm_eventhub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name
  partition_count     = 2
  message_retention   = 1
}

resource "azurerm_storage_account" "test" {
  name                     = "accstorageonrkp"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_container" "test" {
  name                  = "acccontainer240119025423982977"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

resource "azurerm_monitor_data_collection_endpoint" "test" {
  name                = "acctestmdcr-240119025423982977"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_monitor_data_collection_rule" "test" {
  name                        = "acctestmdcr-240119025423982977"
  resource_group_name         = azurerm_resource_group.test.name
  location                    = azurerm_resource_group.test.location
  data_collection_endpoint_id = azurerm_monitor_data_collection_endpoint.test.id
  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.test.id
      name                  = "test-destination-log"
    }

    event_hub {
      event_hub_id = azurerm_eventhub.test.id
      name         = "test-destination-eventhub"
    }

    storage_blob {
      storage_account_id = azurerm_storage_account.test.id
      container_name     = azurerm_storage_container.test.name
      name               = "test-destination-storage"
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

  data_flow {
    streams      = ["Microsoft-Event", "Microsoft-WindowsEvent"]
    destinations = ["test-destination-log"]
  }

  data_flow {
    streams       = ["Custom-MyTableRawData"]
    destinations  = ["test-destination-log"]
    output_stream = "Microsoft-Syslog"
    transform_kql = "source | project TimeGenerated = Time, Computer, Message = AdditionalContext"
  }

  data_sources {
    data_import {
      event_hub_data_source {
        stream         = "Custom-Table_CL"
        name           = "test-datasource-import-event"
        consumer_group = "$Default"
      }
    }

    iis_log {
      streams         = ["Microsoft-W3CIISLog"]
      name            = "test-datasource-iis"
      log_directories = ["C:\\Logs\\W3SVC1"]
    }

    log_file {
      name          = "test-datasource-logfile"
      format        = "text"
      streams       = ["Custom-MyTableRawData"]
      file_patterns = ["C:\\JavaLogs\\*.log"]
      settings {
        text {
          record_start_timestamp_format = "ISO 8601"
        }
      }
    }

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
      name    = "test-datasource-syslog"
      streams = ["Microsoft-Syslog", "Microsoft-CiscoAsa"]
    }

    performance_counter {
      streams                       = ["Microsoft-Perf", "Microsoft-InsightsMetrics"]
      sampling_frequency_in_seconds = 60
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

    prometheus_forwarder {
      label_include_filter {
        label = "microsoft_metrics_include_label"
        value = "testValue"
      }
      streams = ["Microsoft-PrometheusMetrics"]
      name    = "test-datasource-prometheus"
    }

    platform_telemetry {
      streams = ["Microsoft.Cache/redis:Metrics-Group-All"]
      name    = "test-datasource-telemetry"
    }

    windows_event_log {
      streams        = ["Microsoft-WindowsEvent"]
      x_path_queries = ["System!*[System[EventID=4648]]"]
      name           = "test-datasource-wineventlog"
    }

    windows_firewall_log {
      streams = ["Microsoft-ASimNetworkSessionLogs-WindowsFirewall"]
      name    = "test-datasource-windowsfirewall"
    }

    extension {
      streams            = ["Microsoft-WindowsEvent", "Microsoft-ServiceMap"]
      input_data_sources = ["test-datasource-wineventlog"]
      extension_name     = "test-extension-name"
      extension_json = jsonencode({
        a = 1
        b = "hello"
      })
      name = "test-datasource-extension"
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

  stream_declaration {
    stream_name = "Custom-MyTableRawData2"
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

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.test.id]
  }

  description = "acc test monitor_data_collection_rule complete"
  tags = {
    ENV  = "test"
    ENV2 = "test2"
  }

  depends_on = [
    azurerm_log_analytics_solution.test,
  ]
}
