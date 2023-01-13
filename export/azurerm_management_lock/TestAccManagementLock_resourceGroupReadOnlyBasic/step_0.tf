
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230113181626412374"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-230113181626412374"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
