
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-230707005952138089"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "74d438c0-a6d2-47c3-b0b6-78fc1cd4f2e3"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
