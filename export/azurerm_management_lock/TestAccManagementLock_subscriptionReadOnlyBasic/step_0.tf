
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "current" {
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-221021034526016331"
  scope      = data.azurerm_subscription.current.id
  lock_level = "ReadOnly"
}
