
provider "azuread" {}

resource "azuread_application" "test" {
  display_name = "acctestspa-231020040545369695"
}

resource "azuread_service_principal" "test" {
  application_id = azuread_application.test.application_id
}

resource "azurerm_marketplace_role_assignment" "test" {
  name                 = "095ec9f3-9245-4a0f-b719-fc5f7085826b"
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.test.id

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}
