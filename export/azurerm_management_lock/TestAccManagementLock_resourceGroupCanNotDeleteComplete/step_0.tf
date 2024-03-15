
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240315123944595625"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-240315123944595625"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
  notes      = "Hello, World!"
}
