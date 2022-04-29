
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220429070000390926"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220429070000390926"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
}
