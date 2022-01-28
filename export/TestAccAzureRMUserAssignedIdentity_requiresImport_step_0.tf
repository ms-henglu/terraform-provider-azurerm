
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220128082714326304"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestgw73k"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
