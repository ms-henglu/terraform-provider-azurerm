
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-211210034347754476"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "5bf32962-156f-4e40-961b-e245f258faf3"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
