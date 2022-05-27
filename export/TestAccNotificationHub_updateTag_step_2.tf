
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRGpol-220527034518423879"
  location = "West Europe"
}

resource "azurerm_notification_hub_namespace" "test" {
  name                = "acctestnhn-220527034518423879"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  namespace_type      = "NotificationHub"
  sku_name            = "Free"
}

resource "azurerm_notification_hub" "test" {
  name                = "acctestnh-220527034518423879"
  namespace_name      = azurerm_notification_hub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
