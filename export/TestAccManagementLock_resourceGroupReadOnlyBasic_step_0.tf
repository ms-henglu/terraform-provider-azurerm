
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210928055846254481"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-210928055846254481"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
