
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221104005838197444"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-221104005838197444"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
  notes      = "Hello, World!"
}
