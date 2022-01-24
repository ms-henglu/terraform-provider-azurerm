
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220124125555646618"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220124125555646618"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
