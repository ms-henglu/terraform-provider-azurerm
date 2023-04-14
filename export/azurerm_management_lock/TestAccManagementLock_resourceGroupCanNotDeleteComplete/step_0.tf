
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230414022046312466"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-230414022046312466"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
  notes      = "Hello, World!"
}
