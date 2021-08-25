
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210825030142423485"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-210825030142423485"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
