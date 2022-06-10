
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-220610022231202985"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "12e399d7-27be-4ea4-b584-263bb6dd503a"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
