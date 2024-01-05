
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105064524769205"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-240105064524769205"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
  notes      = "Hello, World!"
}
