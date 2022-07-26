
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220726002408861941"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220726002408861941"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
}
