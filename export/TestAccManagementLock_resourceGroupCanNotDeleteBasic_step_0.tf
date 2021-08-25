
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210825045205035314"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-210825045205035314"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
}
