
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220107064609273519"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220107064609273519"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
