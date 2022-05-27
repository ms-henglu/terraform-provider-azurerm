
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-220527023846042265"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "d858558f-18fc-42c2-a774-1ca804f7e51a"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
