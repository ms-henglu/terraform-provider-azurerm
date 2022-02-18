
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220218071215411845"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220218071215411845"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
}
