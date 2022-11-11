
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111014148928319"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-221111014148928319"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
}
