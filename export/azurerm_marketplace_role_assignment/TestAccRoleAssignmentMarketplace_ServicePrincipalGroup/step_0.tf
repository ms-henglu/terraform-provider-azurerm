
provider "azuread" {}

resource "azuread_group" "test" {
  display_name     = "acctestspa-240119024515587120"
  security_enabled = true
}

resource "azurerm_marketplace_role_assignment" "test" {
  name                 = "1a81fb38-0b71-470f-aaa8-9553d5b5a630"
  role_definition_name = "Monitoring Contributor"
  principal_id         = azuread_group.test.id

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}
