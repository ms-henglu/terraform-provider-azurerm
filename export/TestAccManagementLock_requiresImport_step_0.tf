
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220324160757205836"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220324160757205836"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
