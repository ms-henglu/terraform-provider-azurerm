
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220826010540133930"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220826010540133930"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
