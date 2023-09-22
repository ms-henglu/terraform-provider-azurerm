
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922061836117801"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-230922061836117801"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
  notes      = "Hello, World!"
}
