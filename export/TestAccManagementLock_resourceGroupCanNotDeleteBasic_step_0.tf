
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211015015044309379"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-211015015044309379"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
}
