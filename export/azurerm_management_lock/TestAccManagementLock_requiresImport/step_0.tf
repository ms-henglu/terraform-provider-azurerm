
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230414022046311119"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-230414022046311119"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
