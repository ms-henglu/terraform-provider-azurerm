
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210924004809394936"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-210924004809394936"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
}
