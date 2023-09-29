
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230929065615635221"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-230929065615635221"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
