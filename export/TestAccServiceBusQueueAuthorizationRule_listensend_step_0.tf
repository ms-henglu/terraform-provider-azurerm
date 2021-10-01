
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211001021223117551"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctest-211001021223117551"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_servicebus_queue" "test" {
  name                = "acctest-211001021223117551"
  resource_group_name = azurerm_resource_group.test.name
  namespace_name      = azurerm_servicebus_namespace.test.name

  enable_partitioning = true
}

resource "azurerm_servicebus_queue_authorization_rule" "test" {
  name                = "acctest-211001021223117551"
  namespace_name      = azurerm_servicebus_namespace.test.name
  queue_name          = azurerm_servicebus_queue.test.name
  resource_group_name = azurerm_resource_group.test.name

  listen = true
  send   = true
  manage = false
}
