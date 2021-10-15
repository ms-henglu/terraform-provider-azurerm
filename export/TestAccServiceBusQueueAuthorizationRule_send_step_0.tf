
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211015014802686262"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctest-211015014802686262"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_servicebus_queue" "test" {
  name                = "acctest-211015014802686262"
  resource_group_name = azurerm_resource_group.test.name
  namespace_name      = azurerm_servicebus_namespace.test.name

  enable_partitioning = true
}

resource "azurerm_servicebus_queue_authorization_rule" "test" {
  name                = "acctest-211015014802686262"
  namespace_name      = azurerm_servicebus_namespace.test.name
  queue_name          = azurerm_servicebus_queue.test.name
  resource_group_name = azurerm_resource_group.test.name

  listen = false
  send   = true
  manage = false
}
