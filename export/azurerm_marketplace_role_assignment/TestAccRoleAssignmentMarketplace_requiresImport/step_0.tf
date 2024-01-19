
data "azurerm_client_config" "test" {
}

resource "azurerm_marketplace_role_assignment" "test" {
  name                 = "34d3298b-056f-43b4-972d-f4f089664d3c"
  role_definition_name = "Managed Applications Reader"
  principal_id         = data.azurerm_client_config.test.object_id

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}
