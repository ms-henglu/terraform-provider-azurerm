

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230825025045987633"
  location = "West Europe"
}

resource "azurerm_notification_hub_namespace" "test" {
  name                = "acctestnhn-230825025045987633"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  namespace_type      = "NotificationHub"

  sku_name = "Free"

  tags = {
    env = "Test"
  }
}


resource "azurerm_notification_hub_namespace" "import" {
  name                = azurerm_notification_hub_namespace.test.name
  resource_group_name = azurerm_notification_hub_namespace.test.resource_group_name
  location            = azurerm_notification_hub_namespace.test.location
  namespace_type      = azurerm_notification_hub_namespace.test.namespace_type

  sku_name = "Free"
}
