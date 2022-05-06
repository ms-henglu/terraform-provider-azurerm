
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220506020224088335"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctesttx72t"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
