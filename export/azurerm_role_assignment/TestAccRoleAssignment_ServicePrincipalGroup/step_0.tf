
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-230227175117439554"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "0bc3e199-2374-436e-9746-9c48ab19ca0e"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
