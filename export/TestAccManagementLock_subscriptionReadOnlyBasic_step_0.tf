
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "current" {
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220520054530323019"
  scope      = data.azurerm_subscription.current.id
  lock_level = "ReadOnly"
}
