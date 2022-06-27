
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220627130159862633"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220627130159862633"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
