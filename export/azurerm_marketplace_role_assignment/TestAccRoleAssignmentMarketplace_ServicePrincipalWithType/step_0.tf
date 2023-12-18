
provider "azuread" {}

resource "azuread_application" "test" {
  display_name = "acctestspa-231218071242947677"
}

resource "azuread_service_principal" "test" {
  application_id = azuread_application.test.application_id
}

resource "azurerm_marketplace_role_assignment" "test" {
  name                             = "3f91e9dc-9b25-4f06-8f8d-4eca24e647f3"
  role_definition_name             = "Log Analytics Contributor"
  principal_id                     = azuread_service_principal.test.id
  skip_service_principal_aad_check = true

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}
