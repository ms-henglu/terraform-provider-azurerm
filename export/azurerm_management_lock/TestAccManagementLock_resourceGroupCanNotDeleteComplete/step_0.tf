
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230707004649053465"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-230707004649053465"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
  notes      = "Hello, World!"
}
