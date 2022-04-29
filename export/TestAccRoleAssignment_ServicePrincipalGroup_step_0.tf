
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-220429075118834733"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "a3eaa393-d79e-4fe9-bf31-076adcd8aa50"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
