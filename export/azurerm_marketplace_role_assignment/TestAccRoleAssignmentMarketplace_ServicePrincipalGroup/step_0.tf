
provider "azuread" {}

resource "azuread_group" "test" {
  display_name     = "acctestspa-240105060258079734"
  security_enabled = true
}

resource "azurerm_marketplace_role_assignment" "test" {
  name                 = "19e1e793-3768-4e6b-ba0d-092d940fed14"
  role_definition_name = "Monitoring Contributor"
  principal_id         = azuread_group.test.id

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}
