
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_application" "test" {
  display_name = "acctestspa-220826002345028896"
}

resource "azuread_service_principal" "test" {
  application_id = azuread_application.test.application_id
}

resource "azurerm_role_assignment" "test" {
  name                 = "e2e03cea-f7a8-4d16-ba4b-cf8ef5d240d3"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_service_principal.test.id
}
