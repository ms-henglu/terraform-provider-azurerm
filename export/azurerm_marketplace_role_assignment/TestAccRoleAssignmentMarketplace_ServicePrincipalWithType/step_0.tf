
provider "azuread" {}

resource "azuread_application" "test" {
  display_name = "acctestspa-230818023517076289"
}

resource "azuread_service_principal" "test" {
  application_id = azuread_application.test.application_id
}

resource "azurerm_marketplace_role_assignment" "test" {
  name                             = "ec469e9b-522b-45da-ad84-569ab014b16f"
  role_definition_name             = "Reader"
  principal_id                     = azuread_service_principal.test.id
  skip_service_principal_aad_check = true

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}
