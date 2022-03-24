
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220324180728055026"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220324180728055026"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
