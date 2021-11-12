

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211112021228911592"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-211112021228911592"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard"
}

resource "azurerm_servicebus_queue" "test" {
  name                = "acctestservicebusqueue-211112021228911592"
  resource_group_name = azurerm_resource_group.test.name
  namespace_name      = azurerm_servicebus_namespace.test.name
}


resource "azurerm_servicebus_queue" "import" {
  name                = azurerm_servicebus_queue.test.name
  resource_group_name = azurerm_servicebus_queue.test.resource_group_name
  namespace_name      = azurerm_servicebus_queue.test.namespace_name
}
