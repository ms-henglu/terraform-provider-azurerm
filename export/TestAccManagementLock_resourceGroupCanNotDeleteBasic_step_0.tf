
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211105030459294852"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-211105030459294852"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
}
