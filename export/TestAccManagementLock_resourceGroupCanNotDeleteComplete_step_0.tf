
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220627131733669529"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220627131733669529"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
  notes      = "Hello, World!"
}
