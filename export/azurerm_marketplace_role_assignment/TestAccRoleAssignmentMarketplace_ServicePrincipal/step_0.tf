
provider "azuread" {}

resource "azuread_application" "test" {
  display_name = "acctestspa-240311031355090290"
}

resource "azuread_service_principal" "test" {
  application_id = azuread_application.test.application_id
}

resource "azurerm_marketplace_role_assignment" "test" {
  name                 = "e05b0ac1-463d-450b-96e1-2aa8203cf7aa"
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.test.id

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}
