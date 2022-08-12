
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220812015448562528"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestijznh"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
