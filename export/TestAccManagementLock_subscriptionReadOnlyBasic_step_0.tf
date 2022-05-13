
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "current" {
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220513023726553347"
  scope      = data.azurerm_subscription.current.id
  lock_level = "ReadOnly"
}
