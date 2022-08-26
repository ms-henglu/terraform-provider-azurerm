
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220826010327357104"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestjc9so"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
