
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220407231401250252"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220407231401250252"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
