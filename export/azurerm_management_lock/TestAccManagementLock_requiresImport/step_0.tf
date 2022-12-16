
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221216014114182947"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-221216014114182947"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
