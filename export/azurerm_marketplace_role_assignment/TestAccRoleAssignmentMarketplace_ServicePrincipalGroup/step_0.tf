
provider "azuread" {}

resource "azuread_group" "test" {
  display_name     = "acctestspa-231013042942894913"
  security_enabled = true
}

resource "azurerm_marketplace_role_assignment" "test" {
  name                 = "f0a56e50-2206-45f8-8f9b-df463b49b36b"
  role_definition_name = "Monitoring Contributor"
  principal_id         = azuread_group.test.id

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}
