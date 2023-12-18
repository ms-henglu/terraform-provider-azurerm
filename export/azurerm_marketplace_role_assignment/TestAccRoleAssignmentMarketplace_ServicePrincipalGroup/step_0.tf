
provider "azuread" {}

resource "azuread_group" "test" {
  display_name     = "acctestspa-231218071242949081"
  security_enabled = true
}

resource "azurerm_marketplace_role_assignment" "test" {
  name                 = "1fe292c2-2829-4f27-b22a-b7d9de65a249"
  role_definition_name = "Monitoring Contributor"
  principal_id         = azuread_group.test.id

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}
