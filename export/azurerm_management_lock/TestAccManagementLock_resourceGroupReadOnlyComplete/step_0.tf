
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221104005838194740"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-221104005838194740"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
  notes      = "Hello, World!"
}
