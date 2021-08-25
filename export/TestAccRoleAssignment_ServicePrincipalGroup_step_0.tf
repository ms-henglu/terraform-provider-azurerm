
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  name = "acctestspa-210825040511089103"
}

resource "azurerm_role_assignment" "test" {
  name                 = "a57101b5-148b-4647-905c-917fc83c9d50"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
