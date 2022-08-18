
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220818235425683989"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestoiug4"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
