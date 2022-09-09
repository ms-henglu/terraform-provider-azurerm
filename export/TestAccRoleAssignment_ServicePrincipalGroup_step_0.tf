
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-220909033849423261"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "52789ead-3991-4b77-9a88-1323cf82d8df"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
