
provider "azuread" {}

resource "azuread_application" "test" {
  display_name = "acctestspa-230915022905263287"
}

resource "azuread_service_principal" "test" {
  application_id = azuread_application.test.application_id
}

resource "azurerm_marketplace_role_assignment" "test" {
  name                             = "beab8fda-7fc3-4e76-944c-9e6ff582bed5"
  role_definition_name             = "Log Analytics Contributor"
  principal_id                     = azuread_service_principal.test.id
  skip_service_principal_aad_check = true

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}
