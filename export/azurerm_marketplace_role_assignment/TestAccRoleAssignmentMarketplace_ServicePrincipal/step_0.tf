
provider "azuread" {}

resource "azuread_application" "test" {
  display_name = "acctestspa-240112033853115566"
}

resource "azuread_service_principal" "test" {
  application_id = azuread_application.test.application_id
}

resource "azurerm_marketplace_role_assignment" "test" {
  name                 = "4f38bcb4-41ef-43a3-9cfe-153c6b96bcca"
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.test.id

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}
