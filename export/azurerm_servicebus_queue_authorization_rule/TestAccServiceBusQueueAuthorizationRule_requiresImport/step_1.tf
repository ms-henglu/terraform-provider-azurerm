

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230728030645582054"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctest-230728030645582054"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_servicebus_queue" "test" {
  name         = "acctest-230728030645582054"
  namespace_id = azurerm_servicebus_namespace.test.id

  enable_partitioning = true
}

resource "azurerm_servicebus_queue_authorization_rule" "test" {
  name     = "acctest-230728030645582054"
  queue_id = azurerm_servicebus_queue.test.id

  listen = true
  send   = false
  manage = false
}


resource "azurerm_servicebus_queue_authorization_rule" "import" {
  name     = azurerm_servicebus_queue_authorization_rule.test.name
  queue_id = azurerm_servicebus_queue_authorization_rule.test.queue_id

  listen = azurerm_servicebus_queue_authorization_rule.test.listen
  send   = azurerm_servicebus_queue_authorization_rule.test.send
  manage = azurerm_servicebus_queue_authorization_rule.test.manage
}
