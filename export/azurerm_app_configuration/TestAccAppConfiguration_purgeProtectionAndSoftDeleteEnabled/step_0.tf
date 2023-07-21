
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appconfig-230721014403153747"
  location = "West Europe"
}

resource "azurerm_app_configuration" "test" {
  name                       = "testaccappconf230721014403153747"
  resource_group_name        = azurerm_resource_group.test.name
  location                   = azurerm_resource_group.test.location
  sku                        = "standard"
  soft_delete_retention_days = 1
  purge_protection_enabled   = true
}
