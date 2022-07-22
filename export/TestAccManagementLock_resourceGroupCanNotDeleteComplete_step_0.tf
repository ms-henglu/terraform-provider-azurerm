
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220722052438147892"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220722052438147892"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
  notes      = "Hello, World!"
}
