
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220114064554613126"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220114064554613126"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
  notes      = "Hello, World!"
}
