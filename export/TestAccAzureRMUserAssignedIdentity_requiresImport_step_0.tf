
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210830084238025128"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestylhf2"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
