
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "current" {
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-221028172717569451"
  scope      = data.azurerm_subscription.current.id
  lock_level = "ReadOnly"
}
