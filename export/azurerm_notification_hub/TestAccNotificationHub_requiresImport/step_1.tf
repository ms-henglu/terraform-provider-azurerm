

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRGpol-230915023942653430"
  location = "West Europe"
}

resource "azurerm_notification_hub_namespace" "test" {
  name                = "acctestnhn-230915023942653430"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  namespace_type      = "NotificationHub"
  sku_name            = "Free"
}

resource "azurerm_notification_hub" "test" {
  name                = "acctestnh-230915023942653430"
  namespace_name      = azurerm_notification_hub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  tags = {
    env = "Test"
  }
}


resource "azurerm_notification_hub" "import" {
  name                = azurerm_notification_hub.test.name
  namespace_name      = azurerm_notification_hub.test.namespace_name
  resource_group_name = azurerm_notification_hub.test.resource_group_name
  location            = azurerm_notification_hub.test.location
}
