
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220826003225097082"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220826003225097082"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
