
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211210025007600759"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-211210025007600759"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
  notes      = "Hello, World!"
}
