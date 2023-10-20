
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231020041756194353"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-231020041756194353"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
  notes      = "Hello, World!"
}
