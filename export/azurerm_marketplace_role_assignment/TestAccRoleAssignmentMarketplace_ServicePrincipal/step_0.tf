
provider "azuread" {}

resource "azuread_application" "test" {
  display_name = "acctestspa-240315122327826849"
}

resource "azuread_service_principal" "test" {
  application_id = azuread_application.test.application_id
}

resource "azurerm_marketplace_role_assignment" "test" {
  name                 = "8aa8b6d3-1ec3-418f-b2c3-5d7387090dc5"
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.test.id

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}
