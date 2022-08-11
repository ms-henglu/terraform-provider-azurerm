
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220811053800478974"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220811053800478974"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
