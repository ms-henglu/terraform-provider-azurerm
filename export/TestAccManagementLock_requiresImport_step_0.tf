
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211008044902352892"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-211008044902352892"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
