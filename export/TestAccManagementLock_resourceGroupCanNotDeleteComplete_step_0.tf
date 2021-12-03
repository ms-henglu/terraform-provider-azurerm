
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211203161829264121"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-211203161829264121"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
  notes      = "Hello, World!"
}
