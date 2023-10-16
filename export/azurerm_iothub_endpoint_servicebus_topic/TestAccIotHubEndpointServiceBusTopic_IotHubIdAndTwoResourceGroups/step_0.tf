
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-eventhub-231016034057259735"
  location = "West Europe"
}

resource "azurerm_resource_group" "test2" {
  name     = "acctestRG-iothub-231016034057259735"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctest-231016034057259735"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_servicebus_topic" "test" {
  name         = "acctestservicebustopic-231016034057259735"
  namespace_id = azurerm_servicebus_namespace.test.id
}

resource "azurerm_servicebus_topic_authorization_rule" "test" {
  name     = "acctest-231016034057259735"
  topic_id = azurerm_servicebus_topic.test.id

  listen = false
  send   = true
  manage = false
}

resource "azurerm_iothub" "test" {
  name                = "acctestIoTHub-231016034057259735"
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

resource "azurerm_iothub_endpoint_servicebus_topic" "test" {
  resource_group_name = azurerm_resource_group.test.name
  name                = "acctest"
  iothub_id           = azurerm_iothub.test.id

  connection_string = azurerm_servicebus_topic_authorization_rule.test.primary_connection_string
}
