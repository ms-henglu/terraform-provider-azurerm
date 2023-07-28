
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230728030554191206"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-230728030554191206"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
