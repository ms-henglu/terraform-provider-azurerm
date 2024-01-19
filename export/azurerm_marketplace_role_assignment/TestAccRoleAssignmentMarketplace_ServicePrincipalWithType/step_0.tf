
provider "azuread" {}

resource "azuread_application" "test" {
  display_name = "acctestspa-240119024515582039"
}

resource "azuread_service_principal" "test" {
  application_id = azuread_application.test.application_id
}

resource "azurerm_marketplace_role_assignment" "test" {
  name                             = "eb405923-f082-47df-b2d4-76073c694ada"
  role_definition_name             = "Log Analytics Contributor"
  principal_id                     = azuread_service_principal.test.id
  skip_service_principal_aad_check = true

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}
