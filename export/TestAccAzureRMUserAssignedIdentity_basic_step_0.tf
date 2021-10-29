
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211029015908852672"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestyk437"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
