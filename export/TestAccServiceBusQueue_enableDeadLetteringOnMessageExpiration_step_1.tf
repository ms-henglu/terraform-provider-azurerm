
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211015015116824481"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-211015015116824481"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku = "standard"
}

resource "azurerm_servicebus_queue" "test" {
  name                                 = "acctestservicebusqueue-211015015116824481"
  resource_group_name                  = azurerm_resource_group.test.name
  namespace_name                       = azurerm_servicebus_namespace.test.name
  dead_lettering_on_message_expiration = true
}
