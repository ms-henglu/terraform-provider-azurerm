
provider "azuread" {}

resource "azuread_group" "test" {
  display_name     = "acctestspa-231016033408690071"
  security_enabled = true
}

resource "azurerm_marketplace_role_assignment" "test" {
  name                 = "e0e09924-3993-40b7-bdae-c7e4d5b20e3e"
  role_definition_name = "Monitoring Contributor"
  principal_id         = azuread_group.test.id

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}
