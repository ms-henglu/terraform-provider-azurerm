
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220527034703636419"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctest-220527034703636419"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_servicebus_queue" "test" {
  name         = "acctest-220527034703636419"
  namespace_id = azurerm_servicebus_namespace.test.id

  enable_partitioning = true
}

resource "azurerm_servicebus_queue_authorization_rule" "test" {
  name     = "acctest-220527034703636419"
  queue_id = azurerm_servicebus_queue.test.id

  listen = true
  send   = true
  manage = true
}
