
data "azurerm_client_config" "test" {
}

resource "azurerm_marketplace_role_assignment" "test" {
  name                 = "ebc0a114-d77c-4c01-8e79-f5b42b5ea30f"
  role_definition_name = "Log Analytics Reader"
  principal_id         = data.azurerm_client_config.test.object_id

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}
