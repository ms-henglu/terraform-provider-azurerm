
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220623234246010360"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220623234246010360"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
