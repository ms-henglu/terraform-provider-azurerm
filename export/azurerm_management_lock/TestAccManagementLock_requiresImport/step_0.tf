
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221202040340503794"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-221202040340503794"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
