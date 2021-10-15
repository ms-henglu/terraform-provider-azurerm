
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211015014725104032"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-211015014725104032"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
}
