
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220311042937687481"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220311042937687481"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
