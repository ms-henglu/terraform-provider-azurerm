
provider "azuread" {}

resource "azuread_group" "test" {
  display_name     = "acctestspa-231020040545363081"
  security_enabled = true
}

resource "azurerm_marketplace_role_assignment" "test" {
  name                 = "8053d4f6-69de-4b78-ae7a-5266ddbdb07a"
  role_definition_name = "Monitoring Contributor"
  principal_id         = azuread_group.test.id

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}
