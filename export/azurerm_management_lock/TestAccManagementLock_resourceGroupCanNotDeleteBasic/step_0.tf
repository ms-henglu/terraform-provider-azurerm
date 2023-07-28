
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230728033001721726"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-230728033001721726"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
}
