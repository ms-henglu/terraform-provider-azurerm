
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210917032136905258"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-210917032136905258"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
}
