
data "azurerm_client_config" "test" {
}

resource "azurerm_marketplace_role_assignment" "test" {
  name                 = "2b896227-6ea8-483b-8d7f-148b050b88d8"
  role_definition_name = "Log Analytics Reader"
  principal_id         = data.azurerm_client_config.test.object_id

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}
