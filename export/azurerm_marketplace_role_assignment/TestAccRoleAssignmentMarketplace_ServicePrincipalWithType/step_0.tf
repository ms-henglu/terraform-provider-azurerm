
provider "azuread" {}

resource "azuread_application" "test" {
  display_name = "acctestspa-230922060618364879"
}

resource "azuread_service_principal" "test" {
  application_id = azuread_application.test.application_id
}

resource "azurerm_marketplace_role_assignment" "test" {
  name                             = "979ef927-026b-4fd2-b691-0d1060185464"
  role_definition_name             = "Log Analytics Contributor"
  principal_id                     = azuread_service_principal.test.id
  skip_service_principal_aad_check = true

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}
