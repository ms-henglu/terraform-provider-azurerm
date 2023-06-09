
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230609091922811275"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-230609091922811275"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
}
