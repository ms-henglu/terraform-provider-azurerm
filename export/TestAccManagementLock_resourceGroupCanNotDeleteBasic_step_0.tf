
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220311033041415983"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220311033041415983"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
}
