
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220422012305557231"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220422012305557231"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
  notes      = "Hello, World!"
}
