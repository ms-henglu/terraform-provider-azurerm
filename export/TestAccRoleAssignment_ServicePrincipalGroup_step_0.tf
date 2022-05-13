
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-220513022916930928"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "11eff0d5-bbd3-41e1-b020-bea4382c123d"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
