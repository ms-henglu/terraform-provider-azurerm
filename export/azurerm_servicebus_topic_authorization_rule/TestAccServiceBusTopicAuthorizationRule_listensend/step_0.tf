
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230227033411830119"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctest-230227033411830119"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_servicebus_topic" "test" {
  name         = "acctestservicebustopic-230227033411830119"
  namespace_id = azurerm_servicebus_namespace.test.id
}

resource "azurerm_servicebus_topic_authorization_rule" "test" {
  name     = "acctest-230227033411830119"
  topic_id = azurerm_servicebus_topic.test.id

  listen = true
  send   = true
  manage = false
}
