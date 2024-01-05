
provider "azuread" {}

resource "azuread_application" "test" {
  display_name = "acctestspa-240105060258077080"
}

resource "azuread_service_principal" "test" {
  application_id = azuread_application.test.application_id
}

resource "azurerm_marketplace_role_assignment" "test" {
  name                 = "eb15cb50-1748-4e25-926c-03d710ea6107"
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.test.id

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}
