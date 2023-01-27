
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230127050010704124"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-230127050010704124"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
}
