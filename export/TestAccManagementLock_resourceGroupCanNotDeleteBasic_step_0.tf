
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220520054530313254"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220520054530313254"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
}
