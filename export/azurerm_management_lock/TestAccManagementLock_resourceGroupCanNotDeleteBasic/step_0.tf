
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230810144141545029"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-230810144141545029"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
}
