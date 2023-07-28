
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230728033001721702"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-230728033001721702"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
