

data "azurerm_client_config" "test" {
}

resource "azurerm_marketplace_role_assignment" "test" {
  name                 = "313cd159-e51c-4b84-9546-3096b75fdd6c"
  role_definition_name = "Managed Applications Reader"
  principal_id         = data.azurerm_client_config.test.object_id

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}


resource "azurerm_marketplace_role_assignment" "import" {
  name                 = azurerm_marketplace_role_assignment.test.name
  role_definition_name = azurerm_marketplace_role_assignment.test.role_definition_name
  principal_id         = azurerm_marketplace_role_assignment.test.principal_id

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}
