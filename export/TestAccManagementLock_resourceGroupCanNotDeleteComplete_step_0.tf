
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211013072330239352"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-211013072330239352"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
  notes      = "Hello, World!"
}
