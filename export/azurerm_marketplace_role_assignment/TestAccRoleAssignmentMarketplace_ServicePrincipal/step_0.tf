
provider "azuread" {}

resource "azuread_application" "test" {
  display_name = "acctestspa-230818023517070009"
}

resource "azuread_service_principal" "test" {
  application_id = azuread_application.test.application_id
}

resource "azurerm_marketplace_role_assignment" "test" {
  name                 = "4a619670-dacc-4d87-8bba-6bf3500b41ee"
  role_definition_name = "Reader"
  principal_id         = azuread_service_principal.test.id

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}
