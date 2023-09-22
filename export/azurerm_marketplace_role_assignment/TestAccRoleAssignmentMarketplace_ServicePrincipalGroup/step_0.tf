
provider "azuread" {}

resource "azuread_group" "test" {
  display_name     = "acctestspa-230922053619983723"
  security_enabled = true
}

resource "azurerm_marketplace_role_assignment" "test" {
  name                 = "f8eff3e2-6159-4f65-b7bb-6257d7b31498"
  role_definition_name = "Monitoring Contributor"
  principal_id         = azuread_group.test.id

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}
