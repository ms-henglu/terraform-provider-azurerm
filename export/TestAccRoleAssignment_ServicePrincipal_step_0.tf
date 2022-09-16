
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_application" "test" {
  display_name = "acctestspa-220916011112707269"
}

resource "azuread_service_principal" "test" {
  application_id = azuread_application.test.application_id
}

resource "azurerm_role_assignment" "test" {
  name                 = "75bf946e-8d21-474e-a1cd-2af5e294c98c"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_service_principal.test.id
}
