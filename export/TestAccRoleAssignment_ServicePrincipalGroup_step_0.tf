
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-220712041944530765"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "ee1a50be-b511-49fa-b767-bf8fa4a86606"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
