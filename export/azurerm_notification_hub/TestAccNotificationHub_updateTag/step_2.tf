
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRGpol-230804030446896552"
  location = "West Europe"
}

resource "azurerm_notification_hub_namespace" "test" {
  name                = "acctestnhn-230804030446896552"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  namespace_type      = "NotificationHub"
  sku_name            = "Free"
}

resource "azurerm_notification_hub" "test" {
  name                = "acctestnh-230804030446896552"
  namespace_name      = azurerm_notification_hub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
