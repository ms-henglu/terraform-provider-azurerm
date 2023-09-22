
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922061836112060"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-230922061836112060"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
