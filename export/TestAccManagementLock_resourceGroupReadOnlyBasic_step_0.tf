
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221019054854770229"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-221019054854770229"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
