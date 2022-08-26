
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220826010327354926"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestr9qd6"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
