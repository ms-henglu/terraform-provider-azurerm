
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231020041756186453"
  location = "West Europe"
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-231020041756186453"
  scope      = azurerm_resource_group.test.id
  lock_level = "ReadOnly"
}
