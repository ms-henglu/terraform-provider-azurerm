
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230428050439836705"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-230428050439836705"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
  notes      = "Hello, World!"
}
