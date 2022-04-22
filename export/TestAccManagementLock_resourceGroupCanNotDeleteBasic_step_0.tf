
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220422012305553581"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220422012305553581"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
}
