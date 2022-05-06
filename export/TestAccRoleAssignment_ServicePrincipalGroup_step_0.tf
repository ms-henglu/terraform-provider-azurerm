
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-220506005425601480"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "0c0e9830-9e4f-49d7-a7c5-2ec25950b1e5"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
