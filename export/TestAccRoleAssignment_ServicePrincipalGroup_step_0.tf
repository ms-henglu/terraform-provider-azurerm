
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-220603021705745927"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "d8f0a2dd-546e-40be-9b10-137576fd7a14"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
