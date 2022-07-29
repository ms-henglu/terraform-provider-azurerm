
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-220729032342297295"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "5c8273d6-02b2-4146-b3b7-9a117baf64ef"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
