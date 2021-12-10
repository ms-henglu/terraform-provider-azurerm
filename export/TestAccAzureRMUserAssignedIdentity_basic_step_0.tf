
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211210035113627598"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestvr2rl"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
