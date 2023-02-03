
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230203064031575067"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-230203064031575067"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
  notes      = "Hello, World!"
}
