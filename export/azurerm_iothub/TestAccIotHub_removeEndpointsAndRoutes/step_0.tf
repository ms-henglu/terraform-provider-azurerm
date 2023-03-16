
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230316221702329082"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsasstm6"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "test"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

resource "azurerm_eventhub_namespace" "test" {
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  name                = "acctest-230316221702329082"
  sku                 = "Basic"
}

resource "azurerm_eventhub" "test" {
  name                = "acctest"
  resource_group_name = azurerm_resource_group.test.name
  namespace_name      = azurerm_eventhub_namespace.test.name
  partition_count     = 2
  message_retention   = 1
}

resource "azurerm_eventhub_authorization_rule" "test" {
  resource_group_name = azurerm_resource_group.test.name
  namespace_name      = azurerm_eventhub_namespace.test.name
  eventhub_name       = azurerm_eventhub.test.name
  name                = "acctest"
  send                = true
}

resource "azurerm_iothub" "test" {
  name                = "acctestIoTHub-230316221702329082"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku {
    name     = "S1"
    capacity = "1"
  }

  event_hub_retention_in_days = 7
  event_hub_partition_count   = 77

  endpoint {
    type                = "AzureIotHub.StorageContainer"
    connection_string   = azurerm_storage_account.test.primary_blob_connection_string
    name                = "export"
    container_name      = azurerm_storage_container.test.name
    resource_group_name = azurerm_resource_group.test.name
  }

  endpoint {
    type                = "AzureIotHub.EventHub"
    connection_string   = azurerm_eventhub_authorization_rule.test.primary_connection_string
    name                = "export2"
    resource_group_name = azurerm_resource_group.test.name
  }

  route {
    name           = "export"
    source         = "DeviceMessages"
    condition      = "true"
    endpoint_names = ["export"]
    enabled        = true
  }

  route {
    name           = "export2"
    source         = "DeviceMessages"
    condition      = "true"
    endpoint_names = ["export2"]
    enabled        = true
  }

  tags = {
    purpose = "testing"
  }
}
