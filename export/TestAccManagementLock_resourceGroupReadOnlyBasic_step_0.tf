
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211217075748739033"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-211217075748739033"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
