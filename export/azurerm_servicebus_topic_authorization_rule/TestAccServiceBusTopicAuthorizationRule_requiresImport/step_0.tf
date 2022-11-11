
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111014235140318"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctest-221111014235140318"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_servicebus_topic" "test" {
  name         = "acctestservicebustopic-221111014235140318"
  namespace_id = azurerm_servicebus_namespace.test.id
}

resource "azurerm_servicebus_topic_authorization_rule" "test" {
  name     = "acctest-221111014235140318"
  topic_id = azurerm_servicebus_topic.test.id

  listen = true
  send   = false
  manage = false
}
