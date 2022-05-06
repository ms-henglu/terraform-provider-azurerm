
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220506010159628371"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220506010159628371"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
  notes      = "Hello, World!"
}
