
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-220623233252666208"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "fbcd575b-773d-4e60-8b4c-9ab3a7ab3b59"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
