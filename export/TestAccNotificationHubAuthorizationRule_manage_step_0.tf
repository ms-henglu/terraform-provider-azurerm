

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220811053653320151"
  location = "West Europe"
}

resource "azurerm_notification_hub_namespace" "test" {
  name                = "acctestnhn-220811053653320151"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  namespace_type      = "NotificationHub"
  sku_name            = "Free"
}

resource "azurerm_notification_hub" "test" {
  name                = "acctestnh-220811053653320151"
  namespace_name      = azurerm_notification_hub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_notification_hub_authorization_rule" "test" {
  name                  = "acctestrule-220811053653320151"
  notification_hub_name = azurerm_notification_hub.test.name
  namespace_name        = azurerm_notification_hub_namespace.test.name
  resource_group_name   = azurerm_resource_group.test.name
  manage                = true
  send                  = true
  listen                = true
}
