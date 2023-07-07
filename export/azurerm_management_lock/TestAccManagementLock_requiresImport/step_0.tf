
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230707010908445328"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-230707010908445328"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
