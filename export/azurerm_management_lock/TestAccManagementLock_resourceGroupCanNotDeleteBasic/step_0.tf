
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221028165453991463"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-221028165453991463"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
}
