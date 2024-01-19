
provider "azuread" {}

resource "azuread_group" "test" {
  display_name     = "acctestspa-240119021540822955"
  security_enabled = true
}

resource "azurerm_marketplace_role_assignment" "test" {
  name                 = "86cd271a-a915-4926-9654-81d5c9028ea3"
  role_definition_name = "Monitoring Contributor"
  principal_id         = azuread_group.test.id

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}
