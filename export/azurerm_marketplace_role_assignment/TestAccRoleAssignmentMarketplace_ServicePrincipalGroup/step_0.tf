
provider "azuread" {}

resource "azuread_group" "test" {
  display_name     = "acctestspa-230810142938986203"
  security_enabled = true
}

resource "azurerm_marketplace_role_assignment" "test" {
  name                 = "191d9c41-8530-4d99-85d5-11bc7619125e"
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}
