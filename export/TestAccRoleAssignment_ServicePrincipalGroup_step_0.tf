
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-220114013909033912"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "df7111a8-b2e8-4369-b4e9-204e0baba0e0"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
