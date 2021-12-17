

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211217035647478270"
  location = "West Europe"
}

resource "azurerm_notification_hub_namespace" "test" {
  name                = "acctestnhn-211217035647478270"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  namespace_type      = "NotificationHub"
  sku_name            = "Free"
}

resource "azurerm_notification_hub" "test" {
  name                = "acctestnh-211217035647478270"
  namespace_name      = azurerm_notification_hub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_notification_hub_authorization_rule" "test" {
  name                  = "acctestrule-211217035647478270"
  notification_hub_name = azurerm_notification_hub.test.name
  namespace_name        = azurerm_notification_hub_namespace.test.name
  resource_group_name   = azurerm_resource_group.test.name
  listen                = true
}
