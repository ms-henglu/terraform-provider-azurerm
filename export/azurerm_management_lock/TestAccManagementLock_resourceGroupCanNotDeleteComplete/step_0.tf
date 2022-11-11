
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111014148929249"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-221111014148929249"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
  notes      = "Hello, World!"
}
