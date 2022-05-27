
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220527034626261529"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220527034626261529"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
  notes      = "Hello, World!"
}
