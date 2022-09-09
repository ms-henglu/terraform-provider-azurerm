
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220909034908387953"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220909034908387953"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
}
