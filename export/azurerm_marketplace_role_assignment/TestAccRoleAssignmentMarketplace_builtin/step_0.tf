
data "azurerm_client_config" "test" {
}

data "azurerm_role_definition" "test" {
  name = "Monitoring Reader"
}

resource "azurerm_marketplace_role_assignment" "test" {
  name               = "7e6c1470-6959-475b-9712-50d42dcb93b0"
  role_definition_id = "${data.azurerm_role_definition.test.id}"
  principal_id       = data.azurerm_client_config.test.object_id

  lifecycle {
    ignore_changes = [
      role_definition_name,
    ]
  }
}
