
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210825041236889210"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-210825041236889210"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
