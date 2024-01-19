
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025728746743"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-240119025728746743"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
  notes      = "Hello, World!"
}
