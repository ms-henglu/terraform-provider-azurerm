
provider "azuread" {}

resource "azuread_application" "test" {
  display_name = "acctestspa-230728031752022718"
}

resource "azuread_service_principal" "test" {
  application_id = azuread_application.test.application_id
}

resource "azurerm_marketplace_role_assignment" "test" {
  name                             = "37e30f60-2eab-4772-b75f-569ea07d8d3e"
  role_definition_name             = "Reader"
  principal_id                     = azuread_service_principal.test.id
  skip_service_principal_aad_check = true

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}
