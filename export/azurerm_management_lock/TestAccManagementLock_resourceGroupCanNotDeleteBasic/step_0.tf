
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230203064031573985"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-230203064031573985"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
}
