
provider "azuread" {}

resource "azuread_application" "test" {
  display_name = "acctestspa-240105063311290216"
}

resource "azuread_service_principal" "test" {
  application_id = azuread_application.test.application_id
}

resource "azurerm_marketplace_role_assignment" "test" {
  name                 = "a693fdb5-17c4-4694-907a-65713de5c5b5"
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.test.id

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}
