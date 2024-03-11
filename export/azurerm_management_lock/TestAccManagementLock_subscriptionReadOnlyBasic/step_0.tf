
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "current" {
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-240311033021380560"
  scope      = data.azurerm_subscription.current.id
  lock_level = "ReadOnly"
}
