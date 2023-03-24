
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230324052659782068"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-230324052659782068"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
