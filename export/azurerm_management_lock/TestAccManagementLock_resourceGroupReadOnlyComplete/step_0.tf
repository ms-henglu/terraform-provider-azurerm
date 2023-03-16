
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230316222219683798"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-230316222219683798"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
  notes      = "Hello, World!"
}
