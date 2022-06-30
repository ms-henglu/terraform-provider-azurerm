
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220630211256619982"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220630211256619982"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
  notes      = "Hello, World!"
}
