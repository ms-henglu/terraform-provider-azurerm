
provider "azuread" {}

resource "azuread_application" "test" {
  display_name = "acctestspa-230728025052152636"
}

resource "azuread_service_principal" "test" {
  application_id = azuread_application.test.application_id
}

resource "azurerm_marketplace_role_assignment" "test" {
  name                             = "840a3958-9720-480c-98d9-f15650746307"
  role_definition_name             = "Reader"
  principal_id                     = azuread_service_principal.test.id
  skip_service_principal_aad_check = true

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}
