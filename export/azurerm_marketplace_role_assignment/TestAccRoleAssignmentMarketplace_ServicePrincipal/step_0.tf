
provider "azuread" {}

resource "azuread_application" "test" {
  display_name = "acctestspa-230915022905269745"
}

resource "azuread_service_principal" "test" {
  application_id = azuread_application.test.application_id
}

resource "azurerm_marketplace_role_assignment" "test" {
  name                 = "3f8bb18f-b4c8-4c3c-aee5-a9a174934199"
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.test.id

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}
