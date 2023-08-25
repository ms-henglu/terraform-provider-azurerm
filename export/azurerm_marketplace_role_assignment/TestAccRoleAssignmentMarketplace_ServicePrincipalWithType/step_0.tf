
provider "azuread" {}

resource "azuread_application" "test" {
  display_name = "acctestspa-230825024038281292"
}

resource "azuread_service_principal" "test" {
  application_id = azuread_application.test.application_id
}

resource "azurerm_marketplace_role_assignment" "test" {
  name                             = "2ae3b24a-d852-44c6-9604-e7320e7fbad4"
  role_definition_name             = "Log Analytics Contributor"
  principal_id                     = azuread_service_principal.test.id
  skip_service_principal_aad_check = true

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}
