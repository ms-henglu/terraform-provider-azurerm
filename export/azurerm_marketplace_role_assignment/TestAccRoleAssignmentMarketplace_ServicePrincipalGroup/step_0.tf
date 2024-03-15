
provider "azuread" {}

resource "azuread_group" "test" {
  display_name     = "acctestspa-240315122327820719"
  security_enabled = true
}

resource "azurerm_marketplace_role_assignment" "test" {
  name                 = "44ef4135-df3a-4350-a010-7e233c51f451"
  role_definition_name = "Monitoring Contributor"
  principal_id         = azuread_group.test.id

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}
