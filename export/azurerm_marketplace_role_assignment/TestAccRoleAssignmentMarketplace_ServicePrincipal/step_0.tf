
provider "azuread" {}

resource "azuread_application" "test" {
  display_name = "acctestspa-231013042942896551"
}

resource "azuread_service_principal" "test" {
  application_id = azuread_application.test.application_id
}

resource "azurerm_marketplace_role_assignment" "test" {
  name                 = "7dc072d3-a13d-4c81-9ca5-4f368e992927"
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.test.id

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}
