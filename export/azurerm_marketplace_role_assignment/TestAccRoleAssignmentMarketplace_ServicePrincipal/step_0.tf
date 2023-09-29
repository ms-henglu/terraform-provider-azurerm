
provider "azuread" {}

resource "azuread_application" "test" {
  display_name = "acctestspa-230929064400657132"
}

resource "azuread_service_principal" "test" {
  application_id = azuread_application.test.application_id
}

resource "azurerm_marketplace_role_assignment" "test" {
  name                 = "348d1653-c8a1-4ab3-8f51-223a3bb6d6b2"
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.test.id

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}
