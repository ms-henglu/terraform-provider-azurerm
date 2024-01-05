
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-240105063311290215"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "1f2f9af3-a24b-44f3-b435-4a7f9e80c1a8"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
