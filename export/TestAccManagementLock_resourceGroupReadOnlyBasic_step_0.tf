
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220114014708963873"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220114014708963873"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
