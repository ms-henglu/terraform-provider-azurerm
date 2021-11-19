
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211119051341550959"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-211119051341550959"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
  notes      = "Hello, World!"
}
