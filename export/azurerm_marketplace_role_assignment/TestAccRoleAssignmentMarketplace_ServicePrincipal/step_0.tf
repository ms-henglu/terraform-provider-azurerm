
provider "azuread" {}

resource "azuread_application" "test" {
  display_name = "acctestspa-240119024515584546"
}

resource "azuread_service_principal" "test" {
  application_id = azuread_application.test.application_id
}

resource "azurerm_marketplace_role_assignment" "test" {
  name                 = "628431c5-e7c6-4372-b90a-e2876af038a5"
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.test.id

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}
