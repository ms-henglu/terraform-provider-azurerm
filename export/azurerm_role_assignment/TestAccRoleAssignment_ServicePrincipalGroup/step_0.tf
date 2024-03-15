
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-240315122327829926"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "f137b6a5-af29-4849-922b-fba2714fc2ba"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
