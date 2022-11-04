
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221104005838192441"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-221104005838192441"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
}
