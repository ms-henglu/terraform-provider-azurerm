
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221221204753490057"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-221221204753490057"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
}
