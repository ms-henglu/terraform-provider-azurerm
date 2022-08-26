
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "current" {
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220826010540130299"
  scope      = data.azurerm_subscription.current.id
  lock_level = "ReadOnly"
}
