
provider "azuread" {}

resource "azuread_group" "test" {
  display_name     = "acctestspa-230804025429825663"
  security_enabled = true
}

resource "azurerm_marketplace_role_assignment" "test" {
  name                 = "02fec922-f066-480c-b4bd-a55c81235b44"
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}
