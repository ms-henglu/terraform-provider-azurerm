
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-220627123839757662"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "83a23600-e3c3-478e-a3df-28179d844d7d"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
