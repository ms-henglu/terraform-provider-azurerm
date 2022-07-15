
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220715014934200669"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220715014934200669"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
  notes      = "Hello, World!"
}
