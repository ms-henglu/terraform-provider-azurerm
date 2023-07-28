
provider "azuread" {}

resource "azuread_group" "test" {
  display_name     = "acctestspa-230728025052156496"
  security_enabled = true
}

resource "azurerm_marketplace_role_assignment" "test" {
  name                 = "b363f972-ab4f-4cf1-b830-4f4ea84f6255"
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}
