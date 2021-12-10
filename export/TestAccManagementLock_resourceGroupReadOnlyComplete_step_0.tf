
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211210035300314109"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-211210035300314109"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
  notes      = "Hello, World!"
}
