
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220812015659776963"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220812015659776963"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
