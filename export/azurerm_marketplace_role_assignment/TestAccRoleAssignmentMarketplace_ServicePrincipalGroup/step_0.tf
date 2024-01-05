
provider "azuread" {}

resource "azuread_group" "test" {
  display_name     = "acctestspa-240105063311293154"
  security_enabled = true
}

resource "azurerm_marketplace_role_assignment" "test" {
  name                 = "439bacf8-840d-4f47-9eae-ccd3c2ae9501"
  role_definition_name = "Monitoring Contributor"
  principal_id         = azuread_group.test.id

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}
