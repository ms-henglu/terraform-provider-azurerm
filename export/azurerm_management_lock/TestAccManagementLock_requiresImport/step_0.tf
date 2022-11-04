
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221104005838193205"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-221104005838193205"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
