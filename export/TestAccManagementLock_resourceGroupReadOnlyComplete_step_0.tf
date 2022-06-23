
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220623234246012285"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220623234246012285"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
  notes      = "Hello, World!"
}
