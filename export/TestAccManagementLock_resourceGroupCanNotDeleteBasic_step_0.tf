
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211022002407323914"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-211022002407323914"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
}
