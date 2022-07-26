
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "current" {
}

resource "azurerm_management_lock" "test" {
  name       = "acctestlock-220726002408865434"
  scope      = data.azurerm_subscription.current.id
  lock_level = "ReadOnly"
}
