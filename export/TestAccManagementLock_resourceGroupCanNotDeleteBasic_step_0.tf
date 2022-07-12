
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220712042722535353"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220712042722535353"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
}
