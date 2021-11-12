
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211112021143812548"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-211112021143812548"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
}
