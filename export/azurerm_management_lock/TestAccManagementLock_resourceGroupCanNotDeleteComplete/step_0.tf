
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230324052659788977"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-230324052659788977"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
  notes      = "Hello, World!"
}
