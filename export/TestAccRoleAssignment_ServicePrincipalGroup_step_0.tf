
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-220630223417387856"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "06c5d400-d1a5-4369-aeda-17ee7f4a3bf5"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
