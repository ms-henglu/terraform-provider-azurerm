
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220326011116497071"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220326011116497071"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
  notes      = "Hello, World!"
}
