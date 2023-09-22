
provider "azuread" {}

resource "azuread_group" "test" {
  display_name     = "acctestspa-230922060618369270"
  security_enabled = true
}

resource "azurerm_marketplace_role_assignment" "test" {
  name                 = "60ab990b-e452-4244-a40f-ca2281160a5d"
  role_definition_name = "Monitoring Contributor"
  principal_id         = azuread_group.test.id

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}
