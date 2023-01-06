
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-230106034122337439"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "a04702da-a928-4eea-981b-698766402edf"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
