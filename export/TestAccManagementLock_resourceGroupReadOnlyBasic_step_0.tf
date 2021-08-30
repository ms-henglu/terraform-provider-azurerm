
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210830084420872931"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-210830084420872931"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
