
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112035056382626"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-240112035056382626"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
}
