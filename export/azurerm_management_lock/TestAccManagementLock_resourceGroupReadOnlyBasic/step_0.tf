
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230428050439832273"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-230428050439832273"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
