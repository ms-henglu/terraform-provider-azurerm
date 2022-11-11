
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRGpol-221111014016363028"
  location = "West Europe"
}

resource "azurerm_notification_hub_namespace" "test" {
  name                = "acctestnhn-221111014016363028"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  namespace_type      = "NotificationHub"
  sku_name            = "Free"
}

resource "azurerm_notification_hub" "test" {
  name                = "acctestnh-221111014016363028"
  namespace_name      = azurerm_notification_hub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
