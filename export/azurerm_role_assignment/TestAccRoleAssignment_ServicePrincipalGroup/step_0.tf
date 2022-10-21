
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-221021030839512909"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "bbe045d3-573c-4a75-af92-83668f1e3bfb"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
