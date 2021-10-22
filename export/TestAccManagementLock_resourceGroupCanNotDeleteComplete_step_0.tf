
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211022002407326713"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-211022002407326713"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
  notes      = "Hello, World!"
}
