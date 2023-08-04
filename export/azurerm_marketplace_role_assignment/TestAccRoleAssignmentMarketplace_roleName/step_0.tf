
data "azurerm_client_config" "test" {
}

resource "azurerm_marketplace_role_assignment" "test" {
  name                 = "279822cc-fca4-4d73-bed4-081dd59a5e9b"
  role_definition_name = "Log Analytics Reader"
  principal_id         = data.azurerm_client_config.test.object_id

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}
