
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210924011414718572"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-210924011414718572"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
  notes      = "Hello, World!"
}
