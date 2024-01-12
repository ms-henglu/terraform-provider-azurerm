
provider "azuread" {}

resource "azuread_application" "test" {
  display_name = "acctestspa-240112223948229995"
}

resource "azuread_service_principal" "test" {
  application_id = azuread_application.test.application_id
}

resource "azurerm_marketplace_role_assignment" "test" {
  name                 = "94ce53d8-e2ca-44cd-96b1-8c6562cc4fbf"
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.test.id

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}
