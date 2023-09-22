
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922061836111286"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-230922061836111286"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
  notes      = "Hello, World!"
}
