

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220429065849622331"
  location = "West Europe"
}

resource "azurerm_notification_hub_namespace" "test" {
  name                = "acctestnhn-220429065849622331"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  namespace_type      = "NotificationHub"
  sku_name            = "Free"
}

resource "azurerm_notification_hub" "test" {
  name                = "acctestnh-220429065849622331"
  namespace_name      = azurerm_notification_hub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_notification_hub_authorization_rule" "test" {
  name                  = "acctestrule-220429065849622331"
  notification_hub_name = azurerm_notification_hub.test.name
  namespace_name        = azurerm_notification_hub_namespace.test.name
  resource_group_name   = azurerm_resource_group.test.name
  manage                = true
  send                  = true
  listen                = true
}
