
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220712042722534058"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220712042722534058"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
