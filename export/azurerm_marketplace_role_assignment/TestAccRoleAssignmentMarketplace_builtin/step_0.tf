
data "azurerm_client_config" "test" {
}

data "azurerm_role_definition" "test" {
  name = "Log Analytics Reader"
}

resource "azurerm_marketplace_role_assignment" "test" {
  name               = "b229acd7-2525-40b0-93e4-e5a207d5ce6c"
  role_definition_id = "${data.azurerm_role_definition.test.id}"
  principal_id       = data.azurerm_client_config.test.object_id

  lifecycle {
    ignore_changes = [
      role_definition_name,
    ]
  }
}
