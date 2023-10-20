
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231020041756193476"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-231020041756193476"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
}
