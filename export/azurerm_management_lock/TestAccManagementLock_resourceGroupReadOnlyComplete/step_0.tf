
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240311033021382270"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-240311033021382270"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
  notes      = "Hello, World!"
}
