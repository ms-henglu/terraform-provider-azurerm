
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "current" {
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-211001224459939654"
  scope      = data.azurerm_subscription.current.id
  lock_level = "CanNotDelete"
}
