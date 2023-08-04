
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appconfig-230804025344737232"
  location = "West Europe"
}

resource "azurerm_app_configuration" "test" {
  name                     = "testaccappconf230804025344737232"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  sku                      = "standard"
  purge_protection_enabled = "false"
}
