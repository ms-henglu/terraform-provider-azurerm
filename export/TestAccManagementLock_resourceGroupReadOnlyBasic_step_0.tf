
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210910021827330698"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-210910021827330698"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
