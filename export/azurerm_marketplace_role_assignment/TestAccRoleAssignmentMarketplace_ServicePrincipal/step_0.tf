
provider "azuread" {}

resource "azuread_application" "test" {
  display_name = "acctestspa-231218071242942602"
}

resource "azuread_service_principal" "test" {
  application_id = azuread_application.test.application_id
}

resource "azurerm_marketplace_role_assignment" "test" {
  name                 = "b9d522cd-9f49-4113-9bf8-4192e48ea181"
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.test.id

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}
