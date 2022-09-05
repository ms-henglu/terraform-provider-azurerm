
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220905050213474434"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestod7pm"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
