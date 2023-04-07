
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appconfig-230407022841890257"
  location = "West Europe"
}

resource "azurerm_app_configuration" "test" {
  name                = "testacc-appconf230407022841890257"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "free"
}
