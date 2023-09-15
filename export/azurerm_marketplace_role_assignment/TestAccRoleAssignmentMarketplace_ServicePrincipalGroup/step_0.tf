
provider "azuread" {}

resource "azuread_group" "test" {
  display_name     = "acctestspa-230915022905269525"
  security_enabled = true
}

resource "azurerm_marketplace_role_assignment" "test" {
  name                 = "a16a64d3-35f3-45ec-a1c4-380c897954e0"
  role_definition_name = "Monitoring Contributor"
  principal_id         = azuread_group.test.id

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}
