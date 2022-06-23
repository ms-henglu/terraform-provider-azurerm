
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-220623223047563170"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "905bb725-90d0-4ae9-b904-ec62735e1a2c"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
