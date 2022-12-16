
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221216014114180772"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-221216014114180772"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
