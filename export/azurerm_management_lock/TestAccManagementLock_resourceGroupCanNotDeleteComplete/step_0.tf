
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231013044152766976"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-231013044152766976"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
  notes      = "Hello, World!"
}
