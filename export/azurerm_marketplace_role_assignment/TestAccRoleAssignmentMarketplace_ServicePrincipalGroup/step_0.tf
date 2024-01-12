
provider "azuread" {}

resource "azuread_group" "test" {
  display_name     = "acctestspa-240112223948221747"
  security_enabled = true
}

resource "azurerm_marketplace_role_assignment" "test" {
  name                 = "e57dbbdc-5134-4e8e-bd27-28ed0d02dd41"
  role_definition_name = "Monitoring Contributor"
  principal_id         = azuread_group.test.id

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}
