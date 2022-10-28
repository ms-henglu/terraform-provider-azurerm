
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221028172717562427"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-221028172717562427"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
}
