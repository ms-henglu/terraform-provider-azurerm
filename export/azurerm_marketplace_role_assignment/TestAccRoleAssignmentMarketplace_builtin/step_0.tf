
data "azurerm_client_config" "test" {
}

data "azurerm_role_definition" "test" {
  name = "Log Analytics Reader"
}

resource "azurerm_marketplace_role_assignment" "test" {
  name               = "b9c58498-f875-4e2a-b4fb-591f6e2e48ca"
  role_definition_id = "${data.azurerm_role_definition.test.id}"
  principal_id       = data.azurerm_client_config.test.object_id

  lifecycle {
    ignore_changes = [
      role_definition_name,
    ]
  }
}
