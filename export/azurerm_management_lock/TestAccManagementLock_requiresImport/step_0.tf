
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230421022818971108"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-230421022818971108"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
