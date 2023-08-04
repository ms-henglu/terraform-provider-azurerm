
provider "azuread" {}

resource "azuread_application" "test" {
  display_name = "acctestspa-230804025429826511"
}

resource "azuread_service_principal" "test" {
  application_id = azuread_application.test.application_id
}

resource "azurerm_marketplace_role_assignment" "test" {
  name                 = "9152dbdd-6883-4573-bd53-48a3cc4842ff"
  role_definition_name = "Reader"
  principal_id         = azuread_service_principal.test.id

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}
