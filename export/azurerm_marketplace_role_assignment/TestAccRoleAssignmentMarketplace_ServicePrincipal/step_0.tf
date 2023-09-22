
provider "azuread" {}

resource "azuread_application" "test" {
  display_name = "acctestspa-230922060618366222"
}

resource "azuread_service_principal" "test" {
  application_id = azuread_application.test.application_id
}

resource "azurerm_marketplace_role_assignment" "test" {
  name                 = "f59b771a-d7f2-4433-b60d-75b2a8fa9ac2"
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.test.id

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}
