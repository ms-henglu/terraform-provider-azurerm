
provider "azuread" {}

resource "azuread_application" "test" {
  display_name = "acctestspa-230825024038287187"
}

resource "azuread_service_principal" "test" {
  application_id = azuread_application.test.application_id
}

resource "azurerm_marketplace_role_assignment" "test" {
  name                 = "2230ac27-8e31-49a9-b676-a456f3f41eb0"
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.test.id

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}
