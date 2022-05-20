
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220520054323604418"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestq837l"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
