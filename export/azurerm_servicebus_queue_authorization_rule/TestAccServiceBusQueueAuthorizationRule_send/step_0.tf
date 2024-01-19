
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025804619803"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctest-240119025804619803"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_servicebus_queue" "test" {
  name         = "acctest-240119025804619803"
  namespace_id = azurerm_servicebus_namespace.test.id

  enable_partitioning = true
}

resource "azurerm_servicebus_queue_authorization_rule" "test" {
  name     = "acctest-240119025804619803"
  queue_id = azurerm_servicebus_queue.test.id

  listen = false
  send   = true
  manage = false
}
