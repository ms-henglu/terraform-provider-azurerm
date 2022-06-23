
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220623223842825334"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220623223842825334"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
  notes      = "Hello, World!"
}
