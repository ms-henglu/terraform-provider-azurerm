
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230421022818971320"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-230421022818971320"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
