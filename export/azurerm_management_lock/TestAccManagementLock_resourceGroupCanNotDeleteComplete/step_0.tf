
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016034629732302"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-231016034629732302"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
  notes      = "Hello, World!"
}
