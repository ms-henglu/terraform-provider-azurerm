
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221117231417220961"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-221117231417220961"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
  notes      = "Hello, World!"
}
