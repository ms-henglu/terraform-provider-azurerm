
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220415031025508431"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220415031025508431"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
