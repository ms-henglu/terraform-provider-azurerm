
provider "azuread" {}

resource "azuread_application" "test" {
  display_name = "acctestspa-230728031752025895"
}

resource "azuread_service_principal" "test" {
  application_id = azuread_application.test.application_id
}

resource "azurerm_marketplace_role_assignment" "test" {
  name                 = "6e31c4ed-0be7-4530-9f25-2dd46a38eaa3"
  role_definition_name = "Reader"
  principal_id         = azuread_service_principal.test.id

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}
