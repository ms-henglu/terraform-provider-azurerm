
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220218071215415617"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220218071215415617"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
