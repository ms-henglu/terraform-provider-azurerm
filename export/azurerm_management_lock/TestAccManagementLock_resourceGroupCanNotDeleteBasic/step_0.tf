
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112225157597588"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-240112225157597588"
  scope      = azurerm_resource_group.test.id
  lock_level = "CanNotDelete"
}
