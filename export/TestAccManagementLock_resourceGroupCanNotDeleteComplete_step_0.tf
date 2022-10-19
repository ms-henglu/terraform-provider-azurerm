
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221019054854771448"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-221019054854771448"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
  notes      = "Hello, World!"
}
