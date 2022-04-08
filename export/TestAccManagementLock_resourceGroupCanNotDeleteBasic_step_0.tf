
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220408051806610599"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220408051806610599"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
}
