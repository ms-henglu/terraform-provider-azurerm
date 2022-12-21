
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-eventhub-221221204411461474"
  location = "West Europe"
}

resource "azurerm_resource_group" "test2" {
  name     = "acctestRG-iothub-221221204411461474"
  location = "West Europe"
}

resource "azurerm_eventhub_namespace" "test" {
  name                = "acctesteventhubnamespace-221221204411461474"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Basic"
}

resource "azurerm_eventhub" "test" {
  name                = "acctesteventhub-221221204411461474"
  namespace_name      = azurerm_eventhub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name
  partition_count     = 2
  message_retention   = 1
}

resource "azurerm_eventhub_authorization_rule" "test" {
  name                = "acctest-221221204411461474"
  namespace_name      = azurerm_eventhub_namespace.test.name
  eventhub_name       = azurerm_eventhub.test.name
  resource_group_name = azurerm_resource_group.test.name

  listen = false
  send   = true
  manage = false
}

resource "azurerm_iothub" "test" {
  name                = "acctestIoTHub-221221204411461474"
  resource_group_name = azurerm_resource_group.test2.name
  location            = azurerm_resource_group.test2.location

  sku {
    name     = "B1"
    capacity = "1"
  }

  tags = {
    purpose = "testing"
  }
}

resource "azurerm_iothub_endpoint_eventhub" "test" {
  resource_group_name = azurerm_resource_group.test.name
  name                = "acctest"
  iothub_id           = azurerm_iothub.test.id

  connection_string = azurerm_eventhub_authorization_rule.test.primary_connection_string
}
