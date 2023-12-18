
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231218072455217702"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-231218072455217702"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
}
