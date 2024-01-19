
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025548398990"
  location = "West Europe"
}

resource "azurerm_notification_hub_namespace" "test" {
  name                = "acctestnhn-240119025548398990"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  namespace_type      = "NotificationHub"

  sku_name = "Free"

  tags = {
    env = "Test"
  }
}
