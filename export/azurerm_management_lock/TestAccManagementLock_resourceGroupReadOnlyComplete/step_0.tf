
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230728030554198729"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-230728030554198729"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
  notes      = "Hello, World!"
}
