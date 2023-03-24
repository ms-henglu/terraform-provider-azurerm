
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-230324051631190588"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "e2bc8e00-d317-4a55-be3c-e589be22ee8e"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
