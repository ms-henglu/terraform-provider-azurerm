
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220923012254536081"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220923012254536081"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
