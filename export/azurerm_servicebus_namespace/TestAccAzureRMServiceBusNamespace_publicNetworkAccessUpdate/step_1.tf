
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230106031936523056"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                          = "acctestservicebusnamespace-230106031936523056"
  location                      = azurerm_resource_group.test.location
  resource_group_name           = azurerm_resource_group.test.name
  sku                           = "Basic"
  public_network_access_enabled = false
}
