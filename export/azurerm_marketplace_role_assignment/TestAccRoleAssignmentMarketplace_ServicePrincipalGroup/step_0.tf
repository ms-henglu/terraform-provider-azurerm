
provider "azuread" {}

resource "azuread_group" "test" {
  display_name     = "acctestspa-240311031355090635"
  security_enabled = true
}

resource "azurerm_marketplace_role_assignment" "test" {
  name                 = "c40cf0df-daf6-44a7-8341-55938f4d4365"
  role_definition_name = "Monitoring Contributor"
  principal_id         = azuread_group.test.id

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}
