
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220520041119974381"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220520041119974381"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
  notes      = "Hello, World!"
}
