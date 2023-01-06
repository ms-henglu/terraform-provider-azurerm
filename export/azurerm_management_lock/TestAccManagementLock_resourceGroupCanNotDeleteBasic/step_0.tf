
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230106034949877582"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-230106034949877582"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
}
