
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211029020111715888"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-211029020111715888"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
