
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-220107063642723569"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "ffe5f80d-4821-433b-aa55-535801e4d4a3"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
