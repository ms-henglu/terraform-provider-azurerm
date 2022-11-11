
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111020618280496"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsakw4jp"
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
  name                = "acctest-221111020618280496"
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
  name                = "acctestIoTHub-221111020618280496"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku {
    name     = "S1"
    capacity = "1"
  }

  event_hub_retention_in_days = 7
  event_hub_partition_count   = 77

  endpoint = []

  route = []

  tags = {
    purpose = "testing"
  }
}
