
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210830084420870464"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-210830084420870464"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
  notes      = "Hello, World!"
}
