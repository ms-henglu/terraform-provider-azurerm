
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-230707003334286356"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "e4c5aea0-19c5-4376-9dda-84dd935ff1fa"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
