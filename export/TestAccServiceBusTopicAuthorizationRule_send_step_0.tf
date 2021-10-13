
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211013072356021716"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctest-211013072356021716"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_servicebus_topic" "test" {
  name                = "acctestservicebustopic-211013072356021716"
  namespace_name      = azurerm_servicebus_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_servicebus_topic_authorization_rule" "test" {
  name                = "acctest-211013072356021716"
  namespace_name      = azurerm_servicebus_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name
  topic_name          = azurerm_servicebus_topic.test.name

  listen = false
  send   = true
  manage = false
}
