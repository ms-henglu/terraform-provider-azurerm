
provider "azuread" {}

resource "azuread_group" "test" {
  display_name     = "acctestspa-230818023517072986"
  security_enabled = true
}

resource "azurerm_marketplace_role_assignment" "test" {
  name                 = "d50f98f6-3a10-4b21-a7a1-bb56184c9707"
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}
