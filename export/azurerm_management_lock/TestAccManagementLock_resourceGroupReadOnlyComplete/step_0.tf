
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016034629734485"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-231016034629734485"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
  notes      = "Hello, World!"
}
