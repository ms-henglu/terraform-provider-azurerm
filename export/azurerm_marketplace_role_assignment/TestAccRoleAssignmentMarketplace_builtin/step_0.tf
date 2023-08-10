
data "azurerm_client_config" "test" {
}

data "azurerm_role_definition" "test" {
  name = "Log Analytics Reader"
}

resource "azurerm_marketplace_role_assignment" "test" {
  name               = "58cb3032-8ea0-4c0e-8e90-81345b0c8819"
  role_definition_id = "${data.azurerm_role_definition.test.id}"
  principal_id       = data.azurerm_client_config.test.object_id

  lifecycle {
    ignore_changes = [
      role_definition_name,
    ]
  }
}
