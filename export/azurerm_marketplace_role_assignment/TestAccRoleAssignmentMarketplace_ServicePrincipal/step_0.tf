
provider "azuread" {}

resource "azuread_application" "test" {
  display_name = "acctestspa-230728025052152438"
}

resource "azuread_service_principal" "test" {
  application_id = azuread_application.test.application_id
}

resource "azurerm_marketplace_role_assignment" "test" {
  name                 = "7bd74ec6-1e21-4466-a6f4-10a74195bae3"
  role_definition_name = "Reader"
  principal_id         = azuread_service_principal.test.id

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}
