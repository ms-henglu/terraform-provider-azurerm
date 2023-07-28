
provider "azuread" {}

resource "azuread_group" "test" {
  display_name     = "acctestspa-230728031752024580"
  security_enabled = true
}

resource "azurerm_marketplace_role_assignment" "test" {
  name                 = "8a56ffde-4822-4e7c-9c4a-24b046cc2a24"
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}
