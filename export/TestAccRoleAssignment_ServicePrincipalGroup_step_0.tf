
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-220826002345028509"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "9d3dbfc1-8081-4a47-a1f3-15cc9e13e1b2"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
