
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220107034411477364"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220107034411477364"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
}
