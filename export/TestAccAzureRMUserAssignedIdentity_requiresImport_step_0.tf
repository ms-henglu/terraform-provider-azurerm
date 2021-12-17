
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211217035602558902"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestkzqgp"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
