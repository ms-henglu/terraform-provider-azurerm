
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220407231228781959"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestdqgp6"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
