
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-220311042035097940"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "a2f1749b-f2b5-4f4a-9c7f-b4237c433dc7"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
