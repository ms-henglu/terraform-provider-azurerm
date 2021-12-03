
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-211203013434113183"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "79f2f11a-0fea-4d65-a69c-d1594a143873"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
