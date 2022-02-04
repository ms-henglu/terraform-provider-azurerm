
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220204060543047959"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220204060543047959"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
  notes      = "Hello, World!"
}
