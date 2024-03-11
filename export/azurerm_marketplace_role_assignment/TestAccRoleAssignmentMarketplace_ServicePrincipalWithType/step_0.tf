
provider "azuread" {}

resource "azuread_application" "test" {
  display_name = "acctestspa-240311031355092316"
}

resource "azuread_service_principal" "test" {
  application_id = azuread_application.test.application_id
}

resource "azurerm_marketplace_role_assignment" "test" {
  name                             = "3c6cc41a-cf27-43d9-b548-9d79bb644cf4"
  role_definition_name             = "Log Analytics Contributor"
  principal_id                     = azuread_service_principal.test.id
  skip_service_principal_aad_check = true

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}
