
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210910021827339789"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-210910021827339789"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
}
