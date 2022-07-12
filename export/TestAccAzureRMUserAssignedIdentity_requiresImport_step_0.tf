
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220712042546053948"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctest10our"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
