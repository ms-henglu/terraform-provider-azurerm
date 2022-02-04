
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220204093311320660"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestmx1jb"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
