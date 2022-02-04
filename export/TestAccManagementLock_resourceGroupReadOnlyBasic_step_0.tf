
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220204060543047655"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220204060543047655"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
