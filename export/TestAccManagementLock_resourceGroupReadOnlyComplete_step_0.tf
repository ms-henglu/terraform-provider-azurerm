
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220818235553896625"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220818235553896625"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
  notes      = "Hello, World!"
}
