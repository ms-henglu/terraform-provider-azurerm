
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230227033329463395"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-230227033329463395"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
}
