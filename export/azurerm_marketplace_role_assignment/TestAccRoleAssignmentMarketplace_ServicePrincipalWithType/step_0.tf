
provider "azuread" {}

resource "azuread_application" "test" {
  display_name = "acctestspa-230804025429826985"
}

resource "azuread_service_principal" "test" {
  application_id = azuread_application.test.application_id
}

resource "azurerm_marketplace_role_assignment" "test" {
  name                             = "53cdb911-f08a-4ca5-8518-6161c4bc343e"
  role_definition_name             = "Reader"
  principal_id                     = azuread_service_principal.test.id
  skip_service_principal_aad_check = true

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}
