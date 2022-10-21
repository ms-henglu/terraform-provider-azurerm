

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221021034549171184"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-221021034549171184"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard"
}

resource "azurerm_servicebus_queue" "test" {
  name         = "acctestservicebusqueue-221021034549171184"
  namespace_id = azurerm_servicebus_namespace.test.id
}


resource "azurerm_servicebus_queue" "import" {
  name         = azurerm_servicebus_queue.test.name
  namespace_id = azurerm_servicebus_queue.test.namespace_id
}
