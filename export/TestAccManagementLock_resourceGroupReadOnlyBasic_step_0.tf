
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220603022601329681"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220603022601329681"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
