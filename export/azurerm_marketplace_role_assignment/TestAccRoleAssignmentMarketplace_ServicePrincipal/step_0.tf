
provider "azuread" {}

resource "azuread_application" "test" {
  display_name = "acctestspa-230922053619988426"
}

resource "azuread_service_principal" "test" {
  application_id = azuread_application.test.application_id
}

resource "azurerm_marketplace_role_assignment" "test" {
  name                 = "462d1f96-779b-4c9a-8d7e-9938ee91bf85"
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.test.id

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}
