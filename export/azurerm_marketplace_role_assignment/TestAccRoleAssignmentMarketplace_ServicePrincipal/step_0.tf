
provider "azuread" {}

resource "azuread_application" "test" {
  display_name = "acctestspa-231016033408696018"
}

resource "azuread_service_principal" "test" {
  application_id = azuread_application.test.application_id
}

resource "azurerm_marketplace_role_assignment" "test" {
  name                 = "86882c55-388f-4633-8b59-6fb10a92a3f0"
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.test.id

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}
