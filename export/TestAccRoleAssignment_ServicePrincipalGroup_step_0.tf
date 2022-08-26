
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-220826005522654362"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "4f10008c-a781-4ccf-a2eb-94efcaf91524"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
