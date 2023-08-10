
provider "azuread" {}

resource "azuread_application" "test" {
  display_name = "acctestspa-230810142938980110"
}

resource "azuread_service_principal" "test" {
  application_id = azuread_application.test.application_id
}

resource "azurerm_marketplace_role_assignment" "test" {
  name                 = "a7719b12-c025-4af9-a98e-e4b9d28071ce"
  role_definition_name = "Reader"
  principal_id         = azuread_service_principal.test.id

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}
