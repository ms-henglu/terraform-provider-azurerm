
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220726015220117528"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220726015220117528"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
}
