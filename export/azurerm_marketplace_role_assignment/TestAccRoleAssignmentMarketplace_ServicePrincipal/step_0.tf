
provider "azuread" {}

resource "azuread_application" "test" {
  display_name = "acctestspa-240119021540827944"
}

resource "azuread_service_principal" "test" {
  application_id = azuread_application.test.application_id
}

resource "azurerm_marketplace_role_assignment" "test" {
  name                 = "7a36faf6-c9e3-4bcd-9883-ff16a842a9dd"
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.test.id

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}
