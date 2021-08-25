
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210825030142435124"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-210825030142435124"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
}
