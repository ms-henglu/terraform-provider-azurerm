
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210830084420875242"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-210830084420875242"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
