
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-220415030145042045"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "e7d4d681-f0f1-4a81-a7e7-90a5ec0f94ad"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
