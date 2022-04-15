
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220415031106386599"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-220415031106386599"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku = "Standard"
}

resource "azurerm_servicebus_queue" "test" {
  name                                 = "acctestservicebusqueue-220415031106386599"
  namespace_id                         = azurerm_servicebus_namespace.test.id
  dead_lettering_on_message_expiration = true
}
