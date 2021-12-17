
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211217035803374410"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-211217035803374410"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
  notes      = "Hello, World!"
}
