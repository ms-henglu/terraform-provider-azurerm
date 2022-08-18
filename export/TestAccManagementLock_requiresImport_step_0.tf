
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220818235553898075"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220818235553898075"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
