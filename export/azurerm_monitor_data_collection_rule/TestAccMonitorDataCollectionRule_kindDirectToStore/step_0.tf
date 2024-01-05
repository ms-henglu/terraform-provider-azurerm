

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-DataCollectionRule-240105061154827421"
  location = "West Europe"
}



resource "azurerm_eventhub_namespace" "test" {
  name                = "acceventn240105061154827421"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
  capacity            = 1
}

resource "azurerm_eventhub" "test" {
  name                = "accevent240105061154827421"
  namespace_name      = azurerm_eventhub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name
  partition_count     = 2
  message_retention   = 1
}

resource "azurerm_storage_account" "test" {
  name                     = "accstoragesqjk7"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_container" "test" {
  name                  = "acccontainer240105061154827421"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

resource "azurerm_storage_table" "test" {
  name                 = "acctable240105061154827421"
  storage_account_name = azurerm_storage_account.test.name
}

resource "azurerm_monitor_data_collection_rule" "test" {
  name                = "acctestmdcr-240105061154827421"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  kind                = "AgentDirectToStore"
  destinations {
    event_hub_direct {
      name         = "test-destination-eventhub-direct"
      event_hub_id = azurerm_eventhub.test.id
    }
    storage_blob_direct {
      name               = "test-destination-storage-blob-direct"
      storage_account_id = azurerm_storage_account.test.id
      container_name     = azurerm_storage_container.test.name
    }
    storage_table_direct {
      name               = "test-destination-storage-table-direct"
      storage_account_id = azurerm_storage_account.test.id
      table_name         = azurerm_storage_table.test.name
    }
  }

  data_flow {
    streams      = ["Microsoft-Syslog"]
    destinations = ["test-destination-eventhub-direct", "test-destination-storage-blob-direct", "test-destination-storage-table-direct"]
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
      name    = "test-datasource-syslog"
      streams = ["Microsoft-Syslog", "Microsoft-CiscoAsa"]
    }
  }
}
