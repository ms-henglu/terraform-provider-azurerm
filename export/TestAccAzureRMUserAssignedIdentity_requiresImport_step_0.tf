
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220722035656518296"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestbjce9"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
