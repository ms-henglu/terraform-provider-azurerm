
data "azurerm_client_config" "test" {
}

data "azurerm_role_definition" "test" {
  name = "Log Analytics Reader"
}

resource "azurerm_marketplace_role_assignment" "test" {
  name               = "28ba5019-9a2f-4f38-b7e2-5edf24029624"
  role_definition_id = "${data.azurerm_role_definition.test.id}"
  principal_id       = data.azurerm_client_config.test.object_id

  lifecycle {
    ignore_changes = [
      role_definition_name,
    ]
  }
}
