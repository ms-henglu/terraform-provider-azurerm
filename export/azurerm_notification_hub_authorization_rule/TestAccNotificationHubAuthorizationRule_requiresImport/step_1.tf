


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240311032814810175"
  location = "West Europe"
}

resource "azurerm_notification_hub_namespace" "test" {
  name                = "acctestnhn-240311032814810175"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  namespace_type      = "NotificationHub"
  sku_name            = "Free"
}

resource "azurerm_notification_hub" "test" {
  name                = "acctestnh-240311032814810175"
  namespace_name      = azurerm_notification_hub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_notification_hub_authorization_rule" "test" {
  name                  = "acctestrule-240311032814810175"
  notification_hub_name = azurerm_notification_hub.test.name
  namespace_name        = azurerm_notification_hub_namespace.test.name
  resource_group_name   = azurerm_resource_group.test.name
  listen                = true
}


resource "azurerm_notification_hub_authorization_rule" "import" {
  name                  = azurerm_notification_hub_authorization_rule.test.name
  notification_hub_name = azurerm_notification_hub_authorization_rule.test.notification_hub_name
  namespace_name        = azurerm_notification_hub_authorization_rule.test.namespace_name
  resource_group_name   = azurerm_notification_hub_authorization_rule.test.resource_group_name
  listen                = azurerm_notification_hub_authorization_rule.test.listen
}
