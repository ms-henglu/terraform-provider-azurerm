
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_application" "test" {
  display_name = "acctestspa-221111013108645620"
}

resource "azuread_service_principal" "test" {
  application_id = azuread_application.test.application_id
}

resource "azurerm_role_assignment" "test" {
  name                 = "1470bf78-677a-4407-8549-a800ca832edf"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_service_principal.test.id
}
