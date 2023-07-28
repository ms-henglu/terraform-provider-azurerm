
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appconfig-230728031703576142"
  location = "West Europe"
}

resource "azurerm_app_configuration" "test" {
  name                     = "testaccappconf230728031703576142"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  sku                      = "standard"
  purge_protection_enabled = "false"
}
