
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221021034526019803"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-221021034526019803"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
  notes      = "Hello, World!"
}
