
provider "azuread" {}

resource "azuread_group" "test" {
  display_name     = "acctestspa-230825024038284669"
  security_enabled = true
}

resource "azurerm_marketplace_role_assignment" "test" {
  name                 = "d7e8b2ac-fd74-4e8d-84b4-c0895d265132"
  role_definition_name = "Monitoring Contributor"
  principal_id         = azuread_group.test.id

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}
