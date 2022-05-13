
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-220513175933833968"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "0385b51c-bceb-4a89-8f80-45683bc05898"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
