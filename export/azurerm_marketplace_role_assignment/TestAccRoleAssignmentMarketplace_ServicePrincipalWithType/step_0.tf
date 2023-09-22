
provider "azuread" {}

resource "azuread_application" "test" {
  display_name = "acctestspa-230922053619985497"
}

resource "azuread_service_principal" "test" {
  application_id = azuread_application.test.application_id
}

resource "azurerm_marketplace_role_assignment" "test" {
  name                             = "e2ba5949-eddd-4938-97c7-c38ac5caeb1e"
  role_definition_name             = "Log Analytics Contributor"
  principal_id                     = azuread_service_principal.test.id
  skip_service_principal_aad_check = true

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}
