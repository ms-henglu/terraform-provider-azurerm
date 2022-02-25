
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-220225034038990523"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "7ab095bf-7089-4ed4-bd42-7219536d8ab3"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
