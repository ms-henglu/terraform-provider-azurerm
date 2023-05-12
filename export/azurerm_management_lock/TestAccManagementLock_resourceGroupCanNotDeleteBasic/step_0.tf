
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230512004718233803"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-230512004718233803"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
}
