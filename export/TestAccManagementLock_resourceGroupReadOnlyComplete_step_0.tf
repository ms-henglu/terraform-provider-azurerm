
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220114064554616712"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220114064554616712"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
  notes      = "Hello, World!"
}
