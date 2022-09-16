
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220916012012205934"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctest-220916012012205934"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_servicebus_topic" "test" {
  name         = "acctestservicebustopic-220916012012205934"
  namespace_id = azurerm_servicebus_namespace.test.id
}

resource "azurerm_servicebus_topic_authorization_rule" "test" {
  name     = "acctest-220916012012205934"
  topic_id = azurerm_servicebus_topic.test.id

  listen = true
  send   = false
  manage = false
}
