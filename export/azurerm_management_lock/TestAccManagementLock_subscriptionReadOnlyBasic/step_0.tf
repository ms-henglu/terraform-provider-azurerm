
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "current" {
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-221202040340507520"
  scope      = data.azurerm_subscription.current.id
  lock_level = "ReadOnly"
}
