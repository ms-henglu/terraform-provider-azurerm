
provider "azuread" {}

resource "azuread_group" "test" {
  display_name     = "acctestspa-240112033853113992"
  security_enabled = true
}

resource "azurerm_marketplace_role_assignment" "test" {
  name                 = "801ce07f-e2fe-4a67-9394-f33a0443adfd"
  role_definition_name = "Monitoring Contributor"
  principal_id         = azuread_group.test.id

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}
