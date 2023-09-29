
provider "azuread" {}

resource "azuread_group" "test" {
  display_name     = "acctestspa-230929064400656586"
  security_enabled = true
}

resource "azurerm_marketplace_role_assignment" "test" {
  name                 = "c1c5f643-340d-4fa7-adf3-ae0a1a325b5d"
  role_definition_name = "Monitoring Contributor"
  principal_id         = azuread_group.test.id

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}
